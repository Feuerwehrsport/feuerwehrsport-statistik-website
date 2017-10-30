class NewsArticle < ActiveRecord::Base
  belongs_to :admin_user

  default_scope { order(published_at: :desc) }
  scope :admin_user, ->(admin_user_id) { where(admin_user_id: admin_user_id) }

  def next
    @next ||= self.class.where('published_at > ?', published_at).first
  end

  def previous
    @previous ||= self.class.where('published_at < ?', published_at).last
  end
end
