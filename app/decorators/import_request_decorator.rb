class ImportRequestDecorator < AppDecorator
  decorates_association :admin_user
  decorates_association :edit_user
  decorates_association :place
  decorates_association :event
  decorates_association :import_request_files
  localizes_boolean :finished
  localizes :date, :finished_at, :edited_at

  def to_s
    [date, place, event].reject(&:blank?).join(' - ')
  end

  def url_with_link
    h.link_to(url, url) if url.present?
  end
end
