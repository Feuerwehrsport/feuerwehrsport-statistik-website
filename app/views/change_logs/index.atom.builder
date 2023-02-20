# frozen_string_literal: true

atom_feed do |feed|
  feed.title('Feuerwehrsport-Statistik-Veränderungen')
  feed.updated(collection.object.map(&:created_at).max)

  collection.each do |change_log|
    feed.entry(change_log.object, published: change_log.object.created_at) do |entry|
      entry.title(change_log.translated_action)
      entry.content(change_log.readable_content, type: 'html')
      entry.author do |author|
        author.name(change_log.user_name)
      end
    end
  end
end
