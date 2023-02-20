# frozen_string_literal: true

class ResultUploader < M3::ApplicationUploader
  def extension_white_list
    %w[pdf]
  end

  def content_type_allowlist
    [
      'application/pdf',
    ]
  end
end
