# frozen_string_literal: true

class Registrations::Competition < ApplicationRecord
  include UrlSupport
  belongs_to :admin_user
  has_many :bands, inverse_of: :competition, dependent: :destroy, class_name: 'Registrations::Band'
  has_many :assessments, through: :bands, class_name: 'Registrations::Assessment'

  validates :slug, allow_blank: true, format: { with: /\A[a-zA-Z0-9\-_+]*\z/ }
  before_save :generate_slug
  after_create :remove_old_entries

  accepts_nested_attributes_for :assessments, reject_if: :all_blank, allow_destroy: true

  default_scope -> { order(date: :desc) }
  scope :future_records, -> { where(arel_table[:date].gteq(Date.current)) }
  scope :past_records, -> { unscope(where: :date) }
  scope :old_entries, -> { where(arel_table[:date].lt(3.months.ago)) }

  scope :published, -> { where(published: true) }
  scope :overview, -> { where('date >= ?', Date.current) }
  scope :open, -> do
    published
      .where(arel_table[:date].gteq(Date.current))
      .where(arel_table[:open_at].eq(nil).or(arel_table[:open_at].lteq(Time.current)))
      .where(arel_table[:close_at].eq(nil).or(arel_table[:close_at].gteq(Time.current)))
  end

  def slug_url
    registrations_slug_url(slug:)
  end

  def discipline_array
    assessments.pluck(:discipline).uniq
  end

  def possible_assessment_types(assessment)
    return [:competitor] if Discipline.group?(assessment.discipline)

    keys = %i[group_competitor single_competitor out_of_competition]
    keys.shift unless group_score?
    keys
  end

  private

  def generate_slug
    self.slug ||= begin
      slug =  base_slug = decorate.to_s.parameterize
      i = 0
      loop do
        break if self.class.find_by(slug:).blank?

        i += 1
        slug = "#{base_slug}-#{i}"
      end
      slug
    end
  end

  def remove_old_entries
    self.class.old_entries.destroy_all
  end

  Template = Struct.new(:name, :markdown, :block)
  TEMPLATES = [
    Template.new('Löschangriff-Wettkampf', <<~MD,
      * Löschangriff Frauen
      * Löschangriff Männer
    MD
                 ->(c) do
                   band = c.bands.build(name: 'Frauen', gender: :female)
                   band.assessments.build(discipline: :la)
                   band = c.bands.build(name: 'Männer', gender: :male)
                   band.assessments.build(discipline: :la)
                 end),
    Template.new('Löschangriff-Wettkampf mit Jugend', <<~MD,
      * Löschangriff Frauen
      * Löschangriff Männer
      * Löschangriff Jugend
    MD
                 ->(c) do
                   band = c.bands.build(name: 'Frauen', gender: :female)
                   band.assessments.build(discipline: :la)
                   band = c.bands.build(name: 'Männer', gender: :male)
                   band.assessments.build(discipline: :la)
                   band = c.bands.build(name: 'Jugend', gender: :indifferent)
                   band.assessments.build(discipline: :la)
                 end),
    Template.new('Hindernisbahn-Wettkampf', <<~MD,
      * Hindernisbahn Frauen
      * Hindernisbahn Männer
      * Hindernisbahn AK 1 (ungeschlechtlich)
      * Hindernisbahn AK 2 Mädchen
      * Hindernisbahn AK 2 Jungen
    MD
                 ->(c) do
                   band = c.bands.build(name: 'Frauen', gender: :female)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'Männer', gender: :male)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'AK 1', gender: :indifferent)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'AK 2 Mädchen', gender: :female)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'AK 2 Jungen', gender: :male)
                   band.assessments.build(discipline: :hb)
                 end),
    Template.new('Hakenleitersteigen-Wettkampf', <<~MD,
      * Hakenleitersteigen Frauen
      * Hakenleitersteigen Männer
      * Hakenleitersteigen AK 1 (ungeschlechtlich)
      * Hakenleitersteigen AK 2 Mädchen
      * Hakenleitersteigen AK 2 Jungen
    MD
                 ->(c) do
                   band = c.bands.build(name: 'Frauen', gender: :female)
                   band.assessments.build(discipline: :hl)
                   band = c.bands.build(name: 'Männer', gender: :male)
                   band.assessments.build(discipline: :hl)
                   band = c.bands.build(name: 'AK 1', gender: :indifferent)
                   band.assessments.build(discipline: :hl)
                   band = c.bands.build(name: 'AK 2 Mädchen', gender: :female)
                   band.assessments.build(discipline: :hl)
                   band = c.bands.build(name: 'AK 2 Jungen', gender: :male)
                   band.assessments.build(discipline: :hl)
                 end),
    Template.new('Deutschland-Cup', <<~MD,
      * Löschangriff Frauen/Männer
      * 4x100-Meter-Staffel Frauen/Männer
      * Gruppenstafette Frauen
      * HB/HL Frauen (U20 auswählbar)
      * HB/HL Männer (U20 auswählbar)
      * HB/HL AK 1 (ungeschlechtlich)
      * HB/HL AK 2 Mädchen
      * HB/HL AK 2 Jungen
    MD
                 ->(c) do
                   band = c.bands.build(name: 'Frauen', gender: :female)
                   band.assessments.build(discipline: :la)
                   band.assessments.build(discipline: :fs)
                   band.assessments.build(discipline: :gs)
                   band.assessments.build(discipline: :hl)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'Männer', gender: :male)
                   band.assessments.build(discipline: :la)
                   band.assessments.build(discipline: :fs)
                   band.assessments.build(discipline: :hl)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'AK 1', gender: :indifferent)
                   band.assessments.build(discipline: :hl)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'AK 2 Mädchen', gender: :female)
                   band.assessments.build(discipline: :hl)
                   band.assessments.build(discipline: :hb)
                   band = c.bands.build(name: 'AK 2 Jungen', gender: :male)
                   band.assessments.build(discipline: :hl)
                   band.assessments.build(discipline: :hb)
                 end),
    Template.new('Leere Vorlage', <<~MD,
      * Alle Wertungen können manuell angelegt werden
    MD
                 ->(c) {}),
  ].freeze
end
