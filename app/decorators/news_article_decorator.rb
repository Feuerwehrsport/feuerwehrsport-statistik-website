class NewsArticleDecorator < AppDecorator
  decorates_association :admin_user
  decorates_association :next
  decorates_association :previous

  localizes :published_at

  delegate :to_s, to: :title

  def page_title
    "#{title} (#{published_at_date}) - Neuigkeit"
  end

  def content
    object.content&.html_safe # rubocop:disable Rails/OutputSafety
  end
end
