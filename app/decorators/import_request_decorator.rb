class ImportRequestDecorator < AppDecorator
  decorates_association :admin_user
  decorates_association :edit_user
  decorates_association :place
  decorates_association :event

  def to_s
    object.created_at.present? ? l(object.created_at) : 'Neue Anfrage'
  end

  def german_created_at
    l(created_at)
  end

  def finished_label
    finished ? 'Abgeschlossen' : 'Offen'
  end
end
