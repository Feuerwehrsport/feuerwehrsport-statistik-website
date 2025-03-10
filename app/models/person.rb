# frozen_string_literal: true

class Person < ApplicationRecord
  include Genderable
  include People::CacheBuilder

  belongs_to :nation
  has_one :bla_badge, class_name: 'Bla::Badge', dependent: :restrict_with_exception
  has_many :person_participations, dependent: :restrict_with_exception
  has_many :group_scores, through: :person_participations
  has_many :scores, dependent: :restrict_with_exception
  has_many :score_double_events, dependent: :restrict_with_exception
  has_many :group_score_participations, dependent: :restrict_with_exception
  has_many :team_members, dependent: :restrict_with_exception
  has_many :teams, through: :team_members
  has_many :person_spellings, dependent: :restrict_with_exception
  has_many :series_participations, dependent: :restrict_with_exception, class_name: 'Series::PersonParticipation'
  has_many :entity_merges, as: :target, dependent: :restrict_with_exception

  scope :german, -> { nation(1) }
  scope :search, ->(value) do
    search_value = "%#{value}%"
    where('first_name ILIKE ? OR last_name ILIKE ?', search_value, search_value)
  end
  scope :search_exactly, ->(last_name, first_name) do
    where('last_name ILIKE ? AND first_name ILIKE ?', last_name, first_name)
  end
  scope :index_order, -> { order(:last_name, :first_name) }
  scope :where_name_like, ->(name) do
    query = "%#{name.chars.join('%')}%"
    spelling_query = PersonSpelling.where("(first_name || ' ' || last_name) ILIKE ?", query).select(:person_id)
    where("(first_name || ' ' || last_name) ILIKE ? OR id IN (#{spelling_query.to_sql})", query)
  end
  scope :order_by_teams, ->(other_teams) do
    order(other_teams
      .joins(:team_members)
      .where(TeamMember.arel_table[:person_id].eq(arel_table[:id]))
      .select('1')
      .arel.exists
      .desc)
  end
  scope :nation, ->(nation_id) { where(nation_id:) }
  scope :team, ->(team_id) { joins(:team_members).where(team_members: { team_id: }) }
  scope :filter_collection, -> { index_order }
  scope :unused, -> do
    ids = [Bla::Badge, PersonParticipation, Score, Series::PersonParticipation]
          .map { |k| k.select(:person_id).to_sql }.join(' UNION ')
    where(arel_table[:id].not_in(Arel.sql(ids)))
  end

  validates :last_name, :gender, presence: true
  schema_validations

  def merge_to(correct_person)
    raise ActiveRecord::ActiveRecordError, 'same id' if id == correct_person.id

    scores.update_all(person_id: correct_person.id)
    person_participations.update_all(person_id: correct_person.id)
    person_spellings.update_all(person_id: correct_person.id)
    series_participations.update_all(person_id: correct_person.id)
    entity_merges.update_all(target_id: correct_person.id)
    bla_badge.try(:update_attribute, :person_id, correct_person.id)
  end
end
