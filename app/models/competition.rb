class Competition < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :score_type
  has_many :group_score_categories
  has_many :scores

  validates :place, :event, :date, presence: true

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
end
