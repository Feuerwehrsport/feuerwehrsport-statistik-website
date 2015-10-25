class ScoreDoubleEvent < ActiveRecord::Base
  belongs_to :competition
  belongs_to :team

  protected

  def readonly?
    true
  end
end
