class ImportRequestFile < ActiveRecord::Base
  belongs_to :import_request, class_name: 'ImportRequest'
  mount_uploader :file, ImportRequestUploader
end
