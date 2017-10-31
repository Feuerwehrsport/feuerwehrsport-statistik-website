class BLA::Badge < ActiveRecord::Base
  belongs_to :person
  belongs_to :hl_score, class_name: 'Score'
  belongs_to :hb_score, class_name: 'Score'

  scope :person, ->(person_id) { where(person_id: person_id) }

  before_validation do
    self.hl_time ||= hl_score.try(:time)
    self.hb_time ||= hb_score.try(:time)
  end
  validate :score_matches
  validates :hl_time, presence: true, if: -> { person.try(:gender) != :female }

  def <=>(other)
    status_as_index <=> other.status_as_index
  end

  def status_as_index
    case status.try(:to_sym)
    when :gold then 3
    when :silver then 2
    when :bronze then 1
    else 0
    end
  end

  private

  def score_matches
    errors.add(:hl_score, :invalid) if hl_score && hl_score.discipline.to_sym != :hl
    errors.add(:hb_score, :invalid) if hb_score && hb_score.discipline.to_sym != :hb
    errors.add(:hl_score, :invalid) if hl_score && hl_score.person != person
    errors.add(:hb_score, :invalid) if hb_score && hb_score.person != person
    errors.add(:hl_time, :invalid) if hl_score && hl_score.time != hl_time
    errors.add(:hb_time, :invalid) if hb_score && hb_score.time != hb_time
  end
end
