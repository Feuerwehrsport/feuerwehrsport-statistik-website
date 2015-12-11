class ChangeRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin_user

  validates :content, presence: true
end
