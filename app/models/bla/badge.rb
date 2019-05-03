class BLA::Badge < ActiveRecord::Base
  belongs_to :person
  belongs_to :hl_score, class_name: 'Score', inverse_of: :hl_bla_badges
  belongs_to :hb_score, class_name: 'Score', inverse_of: :hb_bla_badges

  scope :person, ->(person_id) { where(person_id: person_id) }

  before_validation do
    self.hl_time ||= hl_score.try(:time)
    self.hb_time ||= hb_score.try(:time)
  end
  validate :score_matches
  validates :hl_time, presence: true, if: -> { person&.gender&.to_sym != :female || year > 2015 }

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

  def current_hl_time
    @current_hl_time ||= next_badge&.hl_score&.time
  end

  def current_hb_time
    @current_hb_time ||= next_badge&.hb_score&.time
  end

  def next_badge
    @next_badge ||= BLA::BadgeGenerator.new.badge_for(person, :gold,
                                                      (hl_time || Firesport::INVALID_TIME) - 1,
                                                      hb_time - 1) { |s| s.reorder(:time) }
  end

  private

  def score_matches
    errors.add(:hl_score, :invalid) if hl_score && hl_score.discipline.to_sym != :hl
    errors.add(:hb_score, :invalid) if hb_score && !hb_score.discipline.to_sym.in?(%i[hb hw])
    errors.add(:hl_score, :invalid) if hl_score && hl_score.person != person
    errors.add(:hb_score, :invalid) if hb_score && hb_score.person != person
    errors.add(:hl_time, :invalid) if hl_score && hl_score.time != hl_time
    errors.add(:hb_time, :invalid) if hb_score && hb_score.time != hb_time
  end
end
