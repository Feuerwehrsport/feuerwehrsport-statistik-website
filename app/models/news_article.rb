# frozen_string_literal: true

class NewsArticle < ApplicationRecord
  belongs_to :admin_user

  default_scope { order(published_at: :desc) }
  scope :admin_user, ->(admin_user_id) { where(admin_user_id: admin_user_id) }

  def next
    @next ||= self.class.where(self.class.arel_table[:published_at].gt(published_at)).reorder(:published_at).first
  end

  def previous
    @previous ||= self.class.where(self.class.arel_table[:published_at].lt(published_at)).reorder(:published_at).last
  end
end
