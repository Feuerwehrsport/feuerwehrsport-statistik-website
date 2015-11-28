class News < ActiveRecord::Base
  belongs_to :admin_user

  validates :admin_user, :published_at, :title, :content, presence: true
end
