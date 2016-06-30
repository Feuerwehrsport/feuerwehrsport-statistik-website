class CompReg::Competitions::Mail < ActiveRecord::Base
  belongs_to :competition, class_name: 'CompReg::Competition'
  belongs_to :admin_user

  validates :subject, :text, presence: true
end
