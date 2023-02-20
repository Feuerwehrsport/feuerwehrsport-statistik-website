# frozen_string_literal: true

class ImportRequestFileDecorator < AppDecorator
  decorates_association :import_request

  def file_with_link
    h.link_to(object.file_identifier, file.to_s) if file.present?
  end
end
