# frozen_string_literal: true

class Competition < ApplicationRecord
  include Competitions::CacheBuilder

  belongs_to :place
  belongs_to :event
  belongs_to :score_type
  has_many :group_score_categories, dependent: :restrict_with_exception
  has_many :group_score_types, through: :group_score_categories
  has_many :scores, dependent: :restrict_with_exception
  has_many :group_scores, through: :group_score_categories
  has_many :score_double_events # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :score_low_double_events # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :links, as: :linkable, dependent: :restrict_with_exception, inverse_of: :linkable
  has_many :competition_files, dependent: :restrict_with_exception, inverse_of: :competition
  has_many :team_competitions # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :teams, through: :team_competitions

  before_validation { self.year = date&.year }
  schema_validations

  scope :with_group_assessment, -> { joins(:score_type) }
  scope :year, ->(year) do
    year = year.is_a?(Year) ? year.year.to_i : year.to_i
    where(year:)
  end
  scope :event, ->(event_id) { where(event_id:) }
  scope :place, ->(place_id) { where(place_id:) }
  scope :score_type, ->(score_type_id) { where(score_type_id:) }
  scope :team, ->(team_id) { joins(:team_competitions).where(team_competitions: { team_id: }) }
  scope :filter_collection, -> { order(date: :desc).includes(:place, :event) }
  scope :search, ->(search_team) do
    search_team_splitted = "%#{search_team.chars.compact_blank.join('%')}%"
    match_list = [
      arel_table[:name],
      Place.arel_table[:name],
      Event.arel_table[:name],
      Arel::Nodes::NamedFunction.new('to_char', [arel_table[:date], Arel::Nodes.build_quoted('DD.MM.YYYY')]),
    ].permutation.to_a.map { |args| Arel::Nodes::NamedFunction.new('concat', args).matches(search_team_splitted) }
    matches = match_list.first
    match_list.drop(1).each { |m| matches = matches.or(m) }

    joins(:place, :event)
      .where(matches)
  end
  scope :bla_badge, -> do
    where(
      arel_table[:hb_male_for_bla_badge].eq(true).or(
        arel_table[:hl_male_for_bla_badge].eq(true).or(
          arel_table[:hb_female_for_bla_badge].eq(true).or(
            arel_table[:hl_female_for_bla_badge].eq(true),
          ),
        ),
      ),
    )
  end

  def group_assessment(single_discipline, gender)
    team_scores = {}
    scores.no_finals.best_of_competition.gender(gender).where(single_discipline:).find_each do |score|
      next if score.team_number < 1 || score.team.nil?

      team_scores[score.uniq_team_id] ||=
        Calculation::CompetitionGroupAssessment.new(score.team, score.team_number, self, gender)
      team_scores[score.uniq_team_id].add_score(score)
    end
    team_scores.values.sort
  end

  def teams
    @teams ||= Team.where("id IN (
      #{group_scores.select(:team_id).to_sql}
      UNION
      #{scores.no_finals.with_team.joins(:person).select(:team_id).to_sql}
    )")
  end

  def missed_information
    @missed_information ||=
      {
        links: links.blank?,
        la_members: group_scores.without_members(:la).present?,
        fs_members: group_scores.without_members(:fs).present?,
        gs_members: group_scores.without_members(:gs).present?,
        single_team: scores.where(team_id: nil).present?,
        competition_files: competition_files.blank?,
      }
  end
end
