# frozen_string_literal: true

class M3::Asset < ApplicationRecord
  mount_uploader :file, M3::AssetUploader
  default_scope { order(:name, :file) }
  before_save do
    self.image = file.image?
    true
  end
  before_validation { self.name = name.presence || file.try(:file).try(:filename) }

  schema_validations
end
