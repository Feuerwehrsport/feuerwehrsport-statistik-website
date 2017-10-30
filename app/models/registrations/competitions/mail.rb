class Registrations::Competitions::Mail < ActiveRecord::Base
  belongs_to :competition, class_name: 'Registrations::Competition'
  belongs_to :admin_user

  validates :subject, :text, presence: true
end
