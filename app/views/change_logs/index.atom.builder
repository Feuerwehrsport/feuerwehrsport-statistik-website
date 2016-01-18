atom_feed do |feed|
  feed.title("Feuerwehrsport-Statistik-Veränderungen")
  feed.updated(@change_logs.map(&:created_at).max)
  
  @change_logs.each do |change_log|
    feed.entry(change_log, published: change_log.created_at) do |entry|
      entry.title(change_log.translated_action)
      entry.content(change_log.diff_hash.to_s)
      entry.author do |author|
        author.name(change_log.user_name)
      end
    end
  end
end