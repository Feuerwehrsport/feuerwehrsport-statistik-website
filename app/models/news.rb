class News < ActiveRecord::Base
  belongs_to :admin_user

  scope :index_order, -> { order(published_at: :desc) }

  validates :admin_user, :published_at, :title, :content, presence: true

  def next
    @next ||= News.where("published_at > ?", published_at).first
  end

  def previous
    @previous ||= News.where("published_at < ?", published_at).last
  end
end
