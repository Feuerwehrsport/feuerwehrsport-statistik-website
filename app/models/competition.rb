class Competition < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :score_type
  has_many :group_score_categories, dependent: :restrict_with_exception
  has_many :group_score_types, through: :group_score_categories
  has_many :scores, dependent: :restrict_with_exception
  has_many :group_scores, through: :group_score_categories
  has_many :score_double_events
  has_many :score_low_double_events
  has_many :links, as: :linkable, dependent: :restrict_with_exception
  has_many :competition_files, dependent: :restrict_with_exception
  has_many :team_competitions
  has_many :teams, through: :team_competitions

  validates :place, :event, :date, presence: true

  scope :with_group_assessment, -> { joins(:score_type) }
  scope :year, ->(year) do
    year_value = year.is_a?(Year) ? year.year.to_i : year.to_i
    where("EXTRACT(YEAR FROM date) = #{year_value}")
  end
  scope :event, ->(event_id) { where(event_id: event_id) }
  scope :place, ->(place_id) { where(place_id: place_id) }
  scope :score_type, ->(score_type_id) { where(score_type_id: score_type_id) }
  scope :team, ->(team_id) { joins(:team_competitions).where(team_competitions: { team_id: team_id }) }
  scope :filter_collection, -> { order(date: :desc).includes(:place, :event) }
  scope :search, ->(search_team) do
    search_team_splitted = "%#{search_team.split('').reject(&:blank?).join('%')}%"
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

  def self.update_discipline_score_count
    hl_female = Score.hl.gender(:female).select('COUNT(*)').where("competition_id = #{table_name}.id").to_sql
    hl_male = Score.hl.gender(:male).select('COUNT(*)').where("competition_id = #{table_name}.id").to_sql
    hb_female = Score.low_and_high_hb.gender(:female).select('COUNT(*)').where("competition_id = #{table_name}.id").to_sql
    hb_male = Score.hb.gender(:male).select('COUNT(*)').where("competition_id = #{table_name}.id").to_sql
    gs = GroupScore.discipline(:gs).select('COUNT(*)').where("group_score_categories.competition_id = #{table_name}.id").to_sql
    fs_female = GroupScore.discipline(:fs).gender(:female).select('COUNT(*)').where("group_score_categories.competition_id = #{table_name}.id").to_sql
    fs_male = GroupScore.discipline(:fs).gender(:male).select('COUNT(*)').where("group_score_categories.competition_id = #{table_name}.id").to_sql
    la_female = GroupScore.discipline(:la).gender(:female).select('COUNT(*)').where("group_score_categories.competition_id = #{table_name}.id").to_sql
    la_male = GroupScore.discipline(:la).gender(:male).select('COUNT(*)').where("group_score_categories.competition_id = #{table_name}.id").to_sql

    group_score_sql = GroupScore
                      .select("CONCAT(team_id,'-',gender,'-',team_number) AS team")
                      .joins(:group_score_category)
                      .where('group_score_categories.competition_id = competitions.id')
                      .to_sql
    score_sql = Score
                .no_finals
                .with_team
                .joins(:person)
                .select("CONCAT(team_id,'-',gender,'-',team_number) AS team")
                .where('competition_id = competitions.id')
                .to_sql
    teams_count_sql = "
      SELECT COUNT(*)
      FROM (
        #{group_score_sql}
        UNION
        #{score_sql}
      ) teams_counts"

    people_sql = Score
                 .group(:person_id)
                 .select(:person_id)
                 .where('competition_id = competitions.id')
                 .to_sql
    person_count_sql = "SELECT COUNT(*) FROM (#{people_sql}) person_count"

    update_all("hl_female = (#{hl_female})")
    update_all("hl_male = (#{hl_male})")
    update_all("hb_female = (#{hb_female})")
    update_all("hb_male = (#{hb_male})")
    update_all("gs = (#{gs})")
    update_all("fs_female = (#{fs_female})")
    update_all("fs_male = (#{fs_male})")
    update_all("la_female = (#{la_female})")
    update_all("la_male = (#{la_male})")
    update_all("teams_count = (#{teams_count_sql})")
    update_all("people_count = (#{person_count_sql})")
  end

  def group_assessment(discipline, gender)
    team_scores = {}
    scores.no_finals.best_of_competition.gender(gender).discipline(discipline).each do |score|
      next if score.team_number < 1 || score.team.nil?

      team_scores[score.uniq_team_id] ||= Calculation::CompetitionGroupAssessment.new(score.team, score.team_number, self, gender)
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

  def year
    date.strftime('%Y').to_i
  end
end
