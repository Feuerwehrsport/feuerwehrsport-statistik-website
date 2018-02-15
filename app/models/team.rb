class Team < ActiveRecord::Base
  include GeoPosition
  include ChangeRequestUploader
  include TeamScopes

  STATUS = { team: 0, fire_station: 1 }.freeze
  enum status: STATUS

  has_many :group_scores, dependent: :restrict_with_exception
  has_many :scores, dependent: :restrict_with_exception
  has_many :person_participations, through: :group_scores
  has_many :group_people, through: :person_participations, class_name: 'Person',
                          foreign_key: 'person_id', source: :person
  has_many :people, through: :scores
  has_many :team_members
  has_many :members, through: :team_members, class_name: 'Person',
                     foreign_key: 'person_id', source: :person
  has_many :team_competitions
  has_many :competitions, through: :team_competitions
  has_many :group_score_participations
  has_many :links, as: :linkable, dependent: :restrict_with_exception
  has_many :team_spellings, dependent: :restrict_with_exception
  has_many :series_participations, dependent: :restrict_with_exception, class_name: 'Series::TeamParticipation'
  has_many :entity_merges, as: :target

  mount_uploader :image, TeamLogoUploader
  change_request_upload(:image)

  validates :name, :shortcut, presence: true

  scope :status, ->(status) { where(status: STATUS[status.to_sym]) }
  scope :index_order, -> { order(:name) }
  scope :search, ->(team_name) { where('name ILIKE ? OR shortcut ILIKE ?', team_name, team_name) }
  scope(:where_name_like, ->(name) do
    name = name.strip.gsub(/^FF\s/i, '').gsub(/^Team\s/i, '').strip

    in_names = Team.select(:id).like_name_or_shortcut(name).to_sql
    in_spellings = TeamSpelling.select(TeamSpelling.arel_table[:team_id].as('id')).like_name_or_shortcut(name).to_sql
    where("#{table_name}.id IN (#{in_names}) OR #{table_name}.id IN (#{in_spellings})")
  end)
  scope :person, ->(person_id) { joins(:team_members).where(team_members: { person_id: person_id }) }
  scope :competition, ->(cid) { joins(:team_competitions).where(team_competitions: { competition_id: cid }) }
  scope :filter_collection, -> { order(:name) }
  scope :unchecked, -> { where(checked_at: nil) }

  def self.update_members_and_competitions_count
    update_all("
      members_count = (#{TeamMember.select('COUNT(*)').where('team_id = teams.id').to_sql}),
      competitions_count = (#{TeamCompetition.select('COUNT(*)').where('team_id = teams.id').to_sql})
    ")
  end

  def person_scores_count(person)
    scores.where(person: person).count + person_participations.where(person: person).count
  end

  def members_with_discipline_count
    all_members = members.map { |member| [member.id, member.becomes(Calculation::TeamPerson)] }.to_h
    scores.group(:person_id, :discipline).count.each do |keys, count|
      all_members[keys.first].increment(keys.last, count)
    end
    person_participations.includes(group_score: { group_score_category: :group_score_type }).each do |participation|
      discipline = participation.group_score.group_score_category.group_score_type.discipline
      all_members[participation.person_id].increment(discipline)
    end
    all_members.values
  end

  def competitions_with_discipline_count
    all_competitions = competitions.map { |comp| [comp.id, comp.becomes(Calculation::TeamCompetition)] }.to_h
    scores.group(:competition_id, :discipline).count.each do |keys, count|
      all_competitions[keys.first].increment(keys.last, count)
    end
    group_scores.includes(group_score_category: :group_score_type).each do |group_score|
      discipline = group_score.group_score_category.group_score_type.discipline
      all_competitions[group_score.group_score_category.competition_id].increment(discipline)
    end
    all_competitions.values
  end

  def group_assessments
    %i[hl hb].map do |discipline|
      %i[female male].map do |gender|
        team_scores = {}
        scores
          .where(competition_id: competitions.with_group_assessment)
          .no_finals
          .best_of_competition
          .gender(gender)
          .discipline(discipline)
          .includes(:competition)
          .each do |score|
          next if score.team_number < 1 || score.team_id.nil?
          team_scores[score.uniq_team_id] ||= Calculation::CompetitionGroupAssessment.new(
            self,
            score.team_number,
            score.competition, gender
          )
          team_scores[score.uniq_team_id].add_score(score)
        end

        OpenStruct.new(
          discipline: discipline,
          gender: gender,
          scores: team_scores.values.map(&:decorate),
        )
      end
    end.flatten
  end

  def group_disciplines
    group_disciplines = []
    %i[gs fs la].each do |discipline|
      %i[female male].each do |gender|
        current_discipline = OpenStruct.new(discipline: discipline, gender: gender, types: [])
        group_score_types(discipline).each do |group_type|
          scores = group_scores.gender(gender).group_score_type(group_type).includes(:person_participations).to_a
          if scores.count.positive?
            current_discipline.types.push(GroupDisciplineType.new(scores.map(&:decorate), group_type))
          end
        end
        group_disciplines.push(current_discipline) if current_discipline.types.count.positive?
      end
    end
    group_disciplines
  end

  def merge_to(correct_team)
    raise ActiveRecord::ActiveRecordError, 'same id' if id == correct_team.id

    scores.update_all(team_id: correct_team.id)
    group_scores.update_all(team_id: correct_team.id)
    links.update_all(linkable_id: correct_team.id)
    team_spellings.update_all(team_id: correct_team.id)
    series_participations.update_all(team_id: correct_team.id)
    entity_merges.update_all(target_id: correct_team.id)
  end

  GroupDisciplineType = Struct.new(:scores, :type) do
    def valid_scores
      @valid_scores ||= scores.reject(&:time_invalid?)
    end

    def best_time
      @best_time ||= scores.sort_by(&:time).first.try(:second_time)
    end

    def average_time
      Firesport::Time.second_time(valid_scores.map(&:time).sum.to_f / valid_scores.size)
    end
  end

  private

  def group_score_types(discipline)
    @group_score_types ||= {}
    @group_score_types[discipline] ||= GroupScoreType.where(discipline: discipline).decorate
  end
end
