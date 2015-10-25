class GroupScoreParticipation < ActiveRecord::Base
  belongs_to :person
  belongs_to :team
  belongs_to :group_score_type
  belongs_to :competition
  
  scope :la, -> { where(discipline: 'la') }
  scope :fs, -> { where(discipline: 'fs') }
  scope :gs, -> { where(discipline: 'gs') }
  scope :valid, -> { where.not(time: Score::INVALID) }
  scope :best_of_competition, -> do
    distinct_column = "CONCAT(#{table_name}.competition_id, '-', #{table_name}.person_id, #{table_name}.discipline)"
    select("DISTINCT ON (#{distinct_column}) #{table_name}.*").order("#{distinct_column}, #{table_name}.time")
  end

  def invalid?
    time == Score::INVALID
  end

  protected

  def readonly?
    true
  end
end
