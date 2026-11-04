# frozen_string_literal: true

require 'rails_helper'

describe CarrierStringIo do
  let(:io) { described_class.new('content', 'file.pdf', 'application/pdf') }

  it 'behaves like uploaded file' do
    expect(io.read).to eq 'content'
    expect(io.original_filename).to eq 'file.pdf'
    expect(io.content_type).to eq 'application/pdf'
  end

  it 'can be stored with carrierwave' do
    import_request = create(:import_request, import_request_files: [])
    file = import_request.import_request_files.create!(file: io)
    expect(file.reload.file.file.filename).to eq 'file.pdf'
    expect(file.file.read).to eq 'content'
  end
end
