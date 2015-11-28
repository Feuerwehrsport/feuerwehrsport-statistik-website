class News < ActiveRecord::Base
  belongs_to :admin_user

  scope :index_order, -> { order(published_at: :desc) }

  validates :admin_user, :published_at, :title, :content, presence: true
end
