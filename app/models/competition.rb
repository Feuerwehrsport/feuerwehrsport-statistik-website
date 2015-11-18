class Competition < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :score_type
  has_many :group_score_categories
  has_many :group_score_types, through: :group_score_categories
  has_many :scores
  has_many :group_scores, through: :group_score_categories
  has_many :score_double_events

  validates :place, :event, :date, presence: true

  scope :with_group_assessment, -> { joins(:score_type) }
  scope :year, -> (year) do
    year_value = year.is_a?(Year) ? year.year.to_i : year.to_i
    where("EXTRACT(YEAR FROM date) = #{year_value}")
  end
  scope :with_disciplines_count, -> do
    hl_female = Score.hl.gender(:female).select("COUNT(*)").where("competition_id = #{table_name}.id").to_sql
    hl_male = Score.hl.gender(:male).select("COUNT(*)").where("competition_id = #{table_name}.id").to_sql
    hb_female = Score.hb.gender(:female).select("COUNT(*)").where("competition_id = #{table_name}.id").to_sql
    hb_male = Score.hb.gender(:male).select("COUNT(*)").where("competition_id = #{table_name}.id").to_sql
    gs = GroupScore.discipline(:gs).select("COUNT(*)").where("group_score_categories.competition_id = #{table_name}.id").to_sql
    fs_female = GroupScore.discipline(:fs).gender(:female).select("COUNT(*)").where("group_score_categories.competition_id = #{table_name}.id").to_sql
    fs_male = GroupScore.discipline(:fs).gender(:male).select("COUNT(*)").where("group_score_categories.competition_id = #{table_name}.id").to_sql
    la_female = GroupScore.discipline(:la).gender(:female).select("COUNT(*)").where("group_score_categories.competition_id = #{table_name}.id").to_sql
    la_male = GroupScore.discipline(:la).gender(:male).select("COUNT(*)").where("group_score_categories.competition_id = #{table_name}.id").to_sql

    select("#{table_name}.*").
    select("(#{hl_female}) AS hl_female").
    select("(#{hl_male}) AS hl_male").
    select("(#{hb_female}) AS hb_female").
    select("(#{hb_male}) AS hb_male").
    select("(#{gs}) AS gs").
    select("(#{fs_female}) AS fs_female").
    select("(#{fs_male}) AS fs_male").
    select("(#{la_female}) AS la_female").
    select("(#{la_male}) AS la_male")
  end

  def team_count
    @team_count ||= self.class.count_by_sql("
      SELECT COUNT(*)
      FROM (
        #{group_scores.select("CONCAT(team_id,'-',gender,'-',team_number) AS team").to_sql}
        UNION
        #{scores.no_finals.with_team.joins(:person).select("CONCAT(team_id,'-',gender,'-',team_number) AS team").to_sql}
      ) i
    ")
  end

  def people_count
    @people_count ||= self.class.count_by_sql("SELECT COUNT(*) FROM (#{scores.group(:person_id).select(:person_id).to_sql}) i")
  end

  def group_assessment(discipline, gender)
    team_scores = {}
    scores.no_finals.best_of_competition.gender(gender).discipline(discipline).each do |score|
      next if score.team_number < 0 || score.team.nil?
      team_scores[score.uniq_team_id] ||= Calculation::CompetitionGroupAssessment.new(score.team, score.team_number, self, gender)
      team_scores[score.uniq_team_id].add_score(score)
    end
    team_scores.values.sort
  end
end
