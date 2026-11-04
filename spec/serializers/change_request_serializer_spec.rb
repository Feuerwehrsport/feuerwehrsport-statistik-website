# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe ChangeRequestSerializer do
  include SerializerSpecHelper

  let(:admin_user) { create(:admin_user, :admin) }
  let(:file) do
    ActionDispatch::Http::UploadedFile.new(
      tempfile: Rails.root.join('spec/fixtures/files/testfile.pdf').open, filename: 'testfile.pdf',
      type: 'application/pdf'
    )
  end
  let(:change_request) do
    travel_to(Time.zone.local(2020, 1, 2, 3, 4, 5)) do
      ChangeRequest.create!(content: { 'key' => 'value' }, user: admin_user, files: [file])
    end
  end

  it 'serializes change request without file content' do
    json = api_json(change_request)
    expect(json.except(:user)).to eq(
      id: change_request.id, content: { key: 'value' }, done_at: nil, created_at: '2020/01/02 03:04:05 +0100',
      files: [{ filename: 'testfile.pdf', content_type: 'application/pdf' }]
    )
    expect(json[:user]).to include(name: 'admin', named_email_address: 'admin <admin@example.com>')
  end

  it 'serializes nil user' do
    change_request.update!(admin_user: nil)
    expect(api_json(change_request)[:user]).to be_nil
  end

  describe ImportRequestFileSerializer do
    it 'serializes file url' do
      import_request_file = create(:import_request).import_request_files.first
      expect(api_json(import_request_file)).to eq(
        id: import_request_file.id,
        file: { url: "/uploads/import_request_file/file/#{import_request_file.id}/testfile.pdf" },
      )
    end
  end
end
