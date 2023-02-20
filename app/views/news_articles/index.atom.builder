# frozen_string_literal: true
atom_feed do |feed|
  feed.title('Feuerwehrsport-Statistik-Neuigkeiten')
  feed.updated(collection.object.map(&:published_at).max)

  collection.each do |news|
    feed.entry(news.object, published: news.object.published_at) do |entry|
      entry.title(news.title)
      entry.content(news.content, type: 'html')
      entry.author do |author|
        author.name(news.admin_user)
      end
    end
  end
end
