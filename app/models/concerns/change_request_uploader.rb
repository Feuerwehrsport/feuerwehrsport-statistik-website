# frozen_string_literal: true

module ChangeRequestUploader
  extend ActiveSupport::Concern

  class_methods do
    def change_request_upload(attribute)
      @change_request_upload_attributes ||= []
      @change_request_upload_attributes.push(attribute)

      define_method(:"#{attribute}_change_request=") do |change_request_ids|
        id, file_id = change_request_ids.split('-')
        files = ChangeRequest.find_by(id:).try(:files) || []
        file = files[file_id.to_i]
        send(:"#{attribute}=", file) if file
      end
    end
  end
end
