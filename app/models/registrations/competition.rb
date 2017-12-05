class Registrations::Competition < ActiveRecord::Base
  include M3::URLSupport
  belongs_to :admin_user
  has_many :assessments, inverse_of: :competition, dependent: :destroy, class_name: 'Registrations::Assessment'
  has_many :teams, dependent: :destroy, class_name: 'Registrations::Team'
  has_many :people, dependent: :destroy, class_name: 'Registrations::Person'

  validates :slug, uniqueness: { case_sensitive: false }, allow_blank: true, format: { with: /\A[a-zA-Z0-9\-_+]*\z/ }
  before_save { self.slug ||= decorate.to_s.parameterize }

  accepts_nested_attributes_for :assessments, reject_if: :all_blank, allow_destroy: true

  default_scope -> { order(date: :desc) }
  scope :future_records, -> { where(arel_table[:date].gteq(Date.current)) }
  scope :past_records, -> { unscope(where: :date) }

  scope :published, -> { where(published: true) }
  scope :overview, -> { where('date >= ?', Date.current) }
  scope :open, -> do
    published
      .where(arel_table[:date].gteq(Date.current))
      .where(arel_table[:open_at].is(nil).or(arel_table[:open_at].lteq(Time.current)))
      .where(arel_table[:close_at].is(nil).or(arel_table[:close_at].gteq(Time.current)))
  end

  def person_tag_list
    person_tags.split(',').each(&:strip!)
  end

  def team_tag_list
    team_tags.split(',').each(&:strip!)
  end

  def slug_url
    registrations_slug_url(slug: slug)
  end

  def discipline_array
    assessments.pluck(:discipline).uniq
  end

  def possible_assessment_types
    keys = Registrations::PersonAssessmentParticipation.assessment_types.keys
    keys.shift unless group_score?
    keys
  end
end
