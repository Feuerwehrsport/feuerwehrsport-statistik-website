class ImportRequestDecorator < AppDecorator
  decorates_association :admin_user
  decorates_association :edit_user
  decorates_association :place
  decorates_association :event
  localizes_boolean :finished
  localizes :date, :finished_at

  def to_s
    [date, place, event, file&.file&.basename].reject(&:blank?).join(' - ')
  end

  def url_with_link
    h.link_to(url, url) if url.present?
  end

  def file_with_link
    h.link_to(file.file.filename, file.to_s) if file.present?
  end
end
