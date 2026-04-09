# frozen_string_literal: true

class Series::RoundImport
  include M3::FormObject
  include ActiveModel::Attributes

  belongs_to :round
  belongs_to :competition
  belongs_to :import_request
  belongs_to :cup
  attribute :import_now, :boolean
  attribute :person_assignments
  attribute :person_assignment_hints
  attribute :team_assignments
  attribute :team_assignment_hints

  validates :competition, :import_request, presence: true

  def save
    return false unless valid?

    create_cup

    import_request.import_data_results.each do |result|
      result[:series_person_round_keys].each do |round_key|
        create_person_participations(result, round_key)
      end

      result[:series_team_round_keys].each do |round_key|
        create_team_participations(result, round_key)
      end
    end
  end

  protected

  def create_cup
    @cup = Series::Cup.create!(round:, competition_id:)
  end

  def find_person_assignment(person_id, first_name, last_name)
    person = Person.find_by(id: person_id)
    person || begin
      person_id = Person.search_exactly(last_name, first_name).pick(:id)
      person_id ||= PersonSpelling.search_exactly(last_name, first_name).pick(:person_id)
      person_id ||= Person.pick(:id)

      key = "#{first_name}__#{last_name}".parameterize
      self.person_assignments ||= {}
      self.person_assignments[key] ||= person_id
      self.person_assignment_hints ||= {}
      self.person_assignment_hints[key] ||= "#{first_name} #{last_name}"

      Person.find_by(id: self.person_assignments[key]) || Person.first
    end
  end

  def find_team_assignment(team_id, orig_team_name)
    team = Team.find_by(id: team_id)
    team || begin
      team_name = Team.normalize_name(orig_team_name)
      team_id = Team.search(team_name).pick(:id)
      team_id ||= TeamSpelling.search(team_name).pick(:team_id)
      team_id ||= Team.pick(:id)

      key = team_name.parameterize
      self.team_assignments ||= {}
      self.team_assignments[key] ||= team_id
      self.team_assignment_hints ||= {}
      self.team_assignment_hints[key] ||= orig_team_name

      Team.find_by(id: self.team_assignments[key]) || Team.first
    end
  end

  def create_person_participations(result, round_key)
    config = Series::AssessmentConfig.find_by_round_key(round_key, :person)
    return if config.nil?
    raise config.disciplines if config.disciplines.count != 1

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
      points = config.points_for_rank[rank - 1] || 0

      # person_id als Integer
      person_id = row[index['statistik_person_id']].to_i
      person = find_person_assignment(person_id, row[index['Vorname']], row[index['Nachname']])

      # Ergebnis als Hundertstel oder 999999
      raw_time = row[index['Bestzeit'] || index['Ergebnis']].to_s.strip

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

    rows = result[:group_rows].presence || result[:rows]

    team_assessment = Series::TeamAssessment.find_or_create_by!(round:, discipline: result[:discipline],
                                                                key: config.key)

    headers = rows.first
    index = headers.each_with_index.to_h
    # => { "Platz"=>0, "Vorname"=>1, ... }

    rows.drop(1).map do |row|
      # Platz als Integer
      rank = row[index['Platz']].to_s.delete('.').to_i
      points = config.points_for_rank[rank - 1] || 0

      # team_id als Integer
      team_id = row[index['statistik_team_id']].to_i
      team_number = row[index['statistik_team_number']].to_i
      team = find_team_assignment(team_id, row[index['Mannschaft'] || index['Name']])
      team_gender = row[index['gender']] == 'female' ? 0 : 1

      # Ergebnis als Hundertstel oder 999999
      raw_time = row[index['Bestzeit'] || index['Ergebnis'] || index['Summe']].to_s.strip

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
end
