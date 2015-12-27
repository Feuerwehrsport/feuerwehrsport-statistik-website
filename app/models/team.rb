class Team < ActiveRecord::Base
  include GeoPosition
  STATUS = { team: 0, fire_station: 1 }
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

  mount_uploader :image, TeamLogoUploader

  validates :name, :shortcut, presence: true

  scope :with_members_and_competitions_count, -> do
    select("
      teams.*,
      (#{TeamMember.select("COUNT(*)").where("team_id = teams.id").to_sql}) AS members_count,
      (#{TeamCompetition.select("COUNT(*)").where("team_id = teams.id").to_sql}) AS competitions_count
    ")
  end
  scope :status, -> (status) { where(status: STATUS[status.to_sym]) }

  def person_scores_count(person)
    scores.where(person: person).count + person_participations.where(person: person).count
  end

  def members_with_discipline_count
    all_members = members.map { |member| [member.id, member.becomes(Calculation::TeamPerson)] }.to_h
    scores.group(:person_id, :discipline).count.each do |keys, count|
      all_members[keys.first].increment(keys.last, count)
    end
    person_participations.includes(group_score: { group_score_category: :group_score_type }).each do |participation|
      all_members[participation.person_id].increment(participation.group_score.group_score_category.group_score_type.discipline)
    end
    all_members.values
  end

  def competitions_with_discipline_count
    all_competitions = competitions.map { |competition| [competition.id, competition.becomes(Calculation::TeamCompetition)] }.to_h
    scores.group(:competition_id, :discipline).count.each do |keys, count|
      all_competitions[keys.first].increment(keys.last, count)
    end
    group_scores.includes(group_score_category: :group_score_type).each do |group_score|
      all_competitions[group_score.group_score_category.competition_id].increment(group_score.group_score_category.group_score_type.discipline)
    end
    all_competitions.values
  end

  def group_assessments
    group_assessments = []
    [:hl, :hb].each do |discipline|
      [:female, :male].each do |gender|
        team_scores = {}
        scores.
            where(competition_id: competitions.with_group_assessment).
            no_finals.
            best_of_competition.
            gender(gender).
            discipline(discipline).
            includes(:competition).
            each do |score|
          next if score.team_number < 0 || score.team_id.nil?
          team_scores[score.uniq_team_id] ||= Calculation::CompetitionGroupAssessment.new(self, score.team_number, score.competition, gender)
          team_scores[score.uniq_team_id].add_score(score)
        end
        group_assessments.push(OpenStruct.new(discipline: discipline, gender: gender, scores: team_scores.values.map(&:decorate)))
      end
    end
    group_assessments
  end

  def group_disciplines
    group_disciplines = []
    [:gs, :fs, :la].each do |discipline|
      [:female, :male].each do |gender|
        current_discipline = OpenStruct.new(discipline: discipline, gender: gender, types: [])
        group_score_types(discipline).each do |group_type|
          scores = group_scores.gender(gender).group_score_type(group_type).includes(:person_participations).to_a
          current_discipline.types.push(OpenStruct.new(scores: scores.map(&:decorate), type: group_type)) if scores.count > 0
        end
        group_disciplines.push(current_discipline) if current_discipline.types.count > 0
      end
    end
    group_disciplines
  end

  private

  def group_score_types(discipline)
    @group_score_types ||= {}
    @group_score_types[discipline] ||= GroupScoreType.where(discipline: discipline).decorate
  end
end
