class ChangeRequest < ActiveRecord::Base 
  belongs_to :user
  belongs_to :admin_user

  validates :content, presence: true

  def content
    super.deep_symbolize_keys
  end
end
