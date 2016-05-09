module CompReg
  class Team < ActiveRecord::Base
    include Genderable
    include Taggable
    belongs_to :competition
    belongs_to :admin_user
    has_many :team_assessment_participations, inverse_of: :team, dependent: :destroy
    has_many :competition_assessments, through: :team_assessment_participations
    has_many :people, inverse_of: :team, dependent: :destroy

    validates :competition, :name, :gender, :shortcut, :admin_user, presence: true
    validates :email_address, email_format: true, allow_blank: true

    accepts_nested_attributes_for :team_assessment_participations, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true

    default_scope -> { order(:name, :team_number) }
    scope :manageable_by, -> (user) do
      team_sql = Team.joins(:competition).merge(Competition.open).where(admin_user_id: user.id).select(:id).to_sql
      competition_sql = Team.joins(:competition).where(comp_reg_competitions: { admin_user_id: user.id }).select(:id).to_sql
      where("id IN ((#{team_sql}) UNION (#{competition_sql}))")
    end

    def self.build_from_last(attributes)
      last_registration = where(attributes).order(:updated_at).last
      if last_registration.present?
        attributes.merge!(last_registration.slice(
          "team_leader",
          "street_with_house_number",
          "postal_code",
          "locality",
          "phone_number",
          "email_address"
        ))
      end
      new(attributes)
    end
  end
end
