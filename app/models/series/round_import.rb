# frozen_string_literal: true

class Series::RoundImport
  include FormObject
  include ActiveModel::Attributes

  belongs_to :round, class_name: 'Series::Round'
  belongs_to :competition
  belongs_to :import_request
  belongs_to :cup, class_name: 'Series::Cup'
  attribute :import_now, :boolean
  attribute :person_assignments
  attribute :person_assignment_ids
  attribute :person_assignment_hints
  attribute :team_assignments
  attribute :team_assignment_ids
  attribute :team_assignment_hints

  validates :competition, :import_request, presence: true
  validate :competition_not_imported
  validate :assignment_ids_exist

  # a competition is only once in a round
  def existing_cup
    return if round.nil? || competition.nil?

    Series::Cup.unscoped.find_by(round_id: round.id, competition_id: competition.id)
  end

  def save
    return false unless valid?

    create_cup

    import_request.import_data_results.each do |result|
      Array(result[:series_person_round_keys]).each do |round_key|
        create_person_participations(result, round_key)
      end

      Array(result[:series_team_round_keys]).each do |round_key|
        create_team_participations(result, round_key)
      end
    end
  end

  protected

  def competition_not_imported
    errors.add(:competition, :already_imported) if existing_cup
  end

  # IDs entered by hand
  def assignment_ids_exist
    { person: Person, team: Team }.each do |type, model|
      ids = Array(public_send(:"#{type}_assignment_ids")&.values).compact_blank
      missing = ids - model.where(id: ids).pluck(:id).map(&:to_s)
      errors.add(:"#{type}_assignment_ids", :not_found, ids: missing.join(', ')) if missing.any?
    end
  end

  def create_cup
    @cup = Series::Cup.create!(round:, competition_id:)
  end

  # people/teams without (valid) ID of Feusport are assigned in the preview: existing record (preselected by name),
  # a new record ("new") or an ID entered by hand
  def find_person_assignment(person_id, first_name, last_name, gender)
    person = Person.find_by(id: person_id) if person_id.positive?
    return person if person

    key = "#{first_name}__#{last_name}".parameterize
    candidates = person_candidates(first_name, last_name, gender)
    assignment_hint(:person, key, "#{first_name} #{last_name}", candidates)
    choice = person_assignment_ids&.[](key).presence || person_assignments&.[](key).presence ||
             candidates.first&.first || 'new'
    return Person.find(choice) unless choice == 'new'
    raise ArgumentError, "Unknown gender for #{first_name} #{last_name}" if gender.blank?

    @created_people ||= {}
    @created_people[key] ||= Person.create!(first_name:, last_name:, gender:, nation_id: 1)
  end

  def find_team_assignment(team_id, orig_team_name)
    team = Team.find_by(id: team_id) if team_id.positive?
    return team if team

    team_name = Team.normalize_name(orig_team_name.to_s)
    key = team_name.parameterize
    candidates = team_candidates(team_name)
    assignment_hint(:team, key, orig_team_name, candidates)
    choice = team_assignment_ids&.[](key).presence || team_assignments&.[](key).presence ||
             candidates.first&.first || 'new'
    return Team.find(choice) unless choice == 'new'

    @created_teams ||= {}
    @created_teams[key] ||= Team.create!(name: "FF #{team_name}", shortcut: team_name, status: :fire_station)
  end

  def assignment_hint(type, key, name, candidates)
    hints = public_send(:"#{type}_assignment_hints") || public_send(:"#{type}_assignment_hints=", {})
    hints[key] ||= { name:, candidates:,
                     selected: public_send(:"#{type}_assignments")&.[](key).presence ||
                               candidates.first&.first&.to_s || 'new',
                     id: public_send(:"#{type}_assignment_ids")&.[](key) }
  end

  def person_candidates(first_name, last_name, gender)
    scope = gender.present? ? Person.gender(gender) : Person.all
    ids = scope.search_exactly(last_name, first_name).pluck(:id)
    ids += PersonSpelling.search_exactly(last_name, first_name).pluck(:person_id)
    ids += scope.where_name_like("#{first_name} #{last_name}").limit(10).pluck(:id)
    ids += scope.where(last_name:).limit(10).pluck(:id)
    Person.where(id: ids.uniq).in_order_of(:id, ids.uniq).decorate.map { [it.id, "#{it.searchable_name} (##{it.id})"] }
  end

  def team_candidates(team_name)
    return [] if team_name.blank?

    ids = Team.search(team_name).pluck(:id) + TeamSpelling.search(team_name).pluck(:team_id)
    ids += Team.where_name_like(team_name).limit(10).pluck(:id)
    Team.where(id: ids.uniq).in_order_of(:id, ids.uniq).map { [it.id, "#{it.name} (##{it.id})"] }
  end

  # gender of the result, otherwise of the row or the key of the assessment
  def person_gender(result, row, index, config)
    [result[:gender], index['gender'] && row[index['gender']], config.key].map(&:to_s).find do |value|
      value.in?(%w[female male])
    end || config.key.to_s[/\A(female|male)/, 1]
  end

  def create_person_participations(result, round_key)
    config = Series::AssessmentConfig.find_by_round_key(round_key, :person)
    return if config.nil?
    return if config.round != round
    if config.disciplines.count != 1
      raise ArgumentError, "Expected exactly one discipline for #{round_key}, got #{config.disciplines.inspect}"
    end

    person_assessment = Series::PersonAssessment.find_or_create_by!(
      round:, discipline: config.disciplines.first, key: config.key,
    )

    rows = result[:rows]

    headers = rows.first
    index = headers.each_with_index.to_h
    # => { "Platz"=>0, "Vorname"=>1, ... }

    rows.drop(1).map do |row|
      # Platz als Integer
      rank = row[index['Platz']].to_s.delete('.').to_i
      points = rank.positive? ? config.points_for_rank[rank - 1] || 0 : 0

      # person_id als Integer
      person_id = row[index['statistik_person_id']].to_i
      person = find_person_assignment(person_id, row[index['Vorname']], row[index['Nachname']],
                                      person_gender(result, row, index, config))

      # Ergebnis als Hundertstel oder 999999
      raw_time = row[index['Bestzeit'] || index['Ergebnis'] || index['time']].to_s.strip

      time = if raw_time.match?(/\A\d+[,.]\d{2}\z/)
               raw_time.delete('.').delete(',')
             else
               Firesport::INVALID_TIME
             end

      correction = import_request.person_points_corrections(round_key, person.id)

      Series::PersonParticipation.create!(
        person_assessment:,
        cup:,
        person:,
        time:,
        points:,
        rank:,
        points_correction: correction&.dig(:points_correction),
        points_correction_hint: correction&.dig(:points_correction_hint),
      )
    end
  end

  def create_team_participations(result, round_key)
    config = Series::AssessmentConfig.find_by_round_key(round_key, :team)
    return if config.nil?
    return if config.round != round

    rows = result[:group_rows].presence || result[:rows]

    team_assessment = Series::TeamAssessment.find_or_create_by!(round:, discipline: result[:discipline],
                                                                key: config.key)

    headers = rows.first
    index = headers.each_with_index.to_h
    # => { "Platz"=>0, "Vorname"=>1, ... }

    rows.drop(1).map do |row|
      # Platz als Integer
      rank = row[index['Platz']].to_s.delete('.').to_i
      points = rank.positive? ? config.points_for_rank[rank - 1] || 0 : 0
      # Ungültige Mannschaften (feusport: zu viele oder zu wenige Starter) bekommen keine Punkte.
      # Ältere Importe haben diese Spalte nicht.
      points = 0 if index.key?('competition_result_valid') && invalid_value?(row[index['competition_result_valid']])

      # team_id als Integer
      team_id = row[index['statistik_team_id']].to_i
      team_number = row[index['statistik_team_number']].to_i
      team = find_team_assignment(team_id, row[index['Mannschaft'] || index['Name']])
      team_gender = row[index['gender']] == 'female' ? 0 : 1

      # Ergebnis als Hundertstel oder 999999
      raw_time = row[index['Bestzeit'] || index['Ergebnis'] || index['Summe'] || index['time']].to_s.strip

      time = if raw_time.match?(/\A\d+[,.]\d{2}\z/)
               raw_time.delete('.').delete(',')
             else
               Firesport::INVALID_TIME
             end

      correction = import_request.team_points_corrections(round_key, team.id, team_number, team_assessment.discipline)

      Series::TeamParticipation.create!(
        team_assessment:,
        cup:,
        team:,
        team_number:,
        team_gender:,
        time:,
        points:,
        rank:,
        points_correction: correction&.dig(:points_correction),
        points_correction_hint: correction&.dig(:points_correction_hint),
      )
    end
  end

  def invalid_value?(value)
    value == false || value.to_s.strip.casecmp?('false')
  end
end
