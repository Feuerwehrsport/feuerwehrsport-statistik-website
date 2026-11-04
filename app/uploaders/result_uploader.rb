# frozen_string_literal: true

class ResultUploader < ApplicationUploader
  def extension_allowlist
    %w[pdf]
  end

  def content_type_allowlist
    [
      'application/pdf',
    ]
  end
end
