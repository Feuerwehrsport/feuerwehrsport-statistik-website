atom_feed do |feed|
  feed.title("Feuerwehrsport-Statistik-Neuigkeiten")
  feed.updated(@news.map(&:published_at).max)
  
  @news.each do |news|
    feed.entry(news, published: news.published_at) do |entry|
      entry.title(news.title)
      entry.content(news.content, type: 'html')
      entry.author do |author|
        author.name(news.admin_user)
      end
    end
  end
end
