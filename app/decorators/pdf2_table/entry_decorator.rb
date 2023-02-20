# frozen_string_literal: true

class Pdf2Table::EntryDecorator < AppDecorator
  decorates_association :admin_user
  localizes :finished_at
  localizes_boolean :success

  def to_s
    "#{pdf.file.filename} vom #{created_at_date}"
  end
end
