# frozen_string_literal: true

class Team < ApplicationRecord
  include GeoPosition
  include ChangeRequestUploader
  include TeamScopes
  include Teams::CacheBuilder

  STATUS = { team: 0, fire_station: 1 }.freeze
  enum status: STATUS

  has_many :group_scores, dependent: :restrict_with_exception
  has_many :scores, dependent: :restrict_with_exception
  has_many :person_participations, through: :group_scores
  has_many :group_people, through: :person_participations, class_name: 'Person',
                          foreign_key: 'person_id', source: :person
  has_many :people, through: :scores
  has_many :team_members # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :members, through: :team_members, class_name: 'Person',
                     foreign_key: 'person_id', source: :person
  has_many :team_competitions # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :competitions, through: :team_competitions
  has_many :group_score_participations # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :links, as: :linkable, dependent: :restrict_with_exception
  has_many :team_spellings, dependent: :restrict_with_exception
  has_many :series_participations, dependent: :restrict_with_exception, class_name: 'Series::TeamParticipation'
  has_many :entity_merges, as: :target, dependent: :restrict_with_exception

  mount_uploader :image, TeamLogoUploader
  change_request_upload(:image)

  validates :name, :shortcut, presence: true

  scope :status, ->(status) { where(status: STATUS[status.to_sym]) }
  scope :index_order, -> { order(:name) }
  scope :search, ->(team_name) { where('name ILIKE ? OR shortcut ILIKE ?', team_name, team_name) }
  scope(:where_name_like, ->(name) do
    name = name.strip.gsub(/^FF\s/i, '').gsub(/^Team\s/i, '').strip

    in_names = Team.unscoped.select(:id).like_name_or_shortcut(name).to_sql
    in_spellings = TeamSpelling.select(TeamSpelling.arel_table[:team_id].as('id')).like_name_or_shortcut(name).to_sql
    where("#{table_name}.id IN (#{in_names}) OR #{table_name}.id IN (#{in_spellings})")
  end)
  scope :person, ->(person_id) { joins(:team_members).where(team_members: { person_id: }) }
  scope :competition, ->(cid) { joins(:team_competitions).where(team_competitions: { competition_id: cid }) }
  scope :filter_collection, -> { index_order }
  scope :unchecked, -> { where(checked_at: nil) }

  def self.update_members_and_competitions_count
    update_all("
      members_count = (#{TeamMember.select('COUNT(*)').where('team_id = teams.id').to_sql}),
      competitions_count = (#{TeamCompetition.select('COUNT(*)').where('team_id = teams.id').to_sql})
    ")
  end

  def person_scores_count(person)
    scores.where(person:).count + person_participations.where(person:).count
  end

  def members_with_discipline_count
    all_members = members.to_h { |member| [member.id, member.becomes(Calculation::TeamPerson)] }
    scores.group(:person_id, :discipline).count.each do |keys, count|
      all_members[keys.first].increment(keys.last, count)
    end
    person_participations.includes(group_score: { group_score_category: :group_score_type })
                         .find_each do |participation|
      discipline = participation.group_score.group_score_category.group_score_type.discipline
      all_members[participation.person_id].increment(discipline)
    end
    all_members.values
  end

  def competitions_with_discipline_count
    all_competitions = competitions.to_h { |comp| [comp.id, comp.becomes(Calculation::TeamCompetition)] }
    scores.group(:competition_id, :discipline).count.each do |keys, count|
      all_competitions[keys.first].increment(keys.last, count)
    end
    group_scores.includes(group_score_category: :group_score_type).find_each do |group_score|
      discipline = group_score.group_score_category.group_score_type.discipline
      all_competitions[group_score.group_score_category.competition_id].increment(discipline)
    end
    all_competitions.values
  end

  GroupAssessment = Struct.new(:discipline, :gender, :scores)

  def group_assessments
    genders = Genderable::GENDER_KEYS.freeze

    %i[hl hb hw].map do |discipline|
      genders.map do |gender|
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

        GroupAssessment.new(
          discipline,
          gender,
          team_scores.values.map(&:decorate),
        )
      end
    end.flatten
  end

  GroupDiscipline = Struct.new(:discipline, :gender, :types)

  def group_disciplines
    genders = Genderable::GENDER_KEYS.freeze

    group_disciplines = []
    %i[gs fs la].each do |discipline|
      genders.each do |gender|
        current_discipline = GroupDiscipline.new(discipline, gender, [])
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
      @best_time ||= scores.min_by(&:time).try(:second_time)
    end

    def average_time
      Firesport::Time.second_time(valid_scores.sum(&:time).to_f / valid_scores.size)
    end
  end

  private

  def group_score_types(discipline)
    @group_score_types ||= {}
    @group_score_types[discipline] ||= GroupScoreType.where(discipline:).decorate
  end
end
