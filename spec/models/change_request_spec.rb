# frozen_string_literal: true

require 'rails_helper'

describe ChangeRequest do
  let(:api_user) { create(:api_user) }
  let(:admin_user) { create(:admin_user) }
  let(:change_request) { described_class.new(content: { key: 'foo', data: { 'bar' => 1 } }) }
  let(:uploaded_file) do
    Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/testfile.png'), 'image/png')
  end
  let(:http_uploaded_file) do
    ActionDispatch::Http::UploadedFile.new(
      tempfile: uploaded_file.tempfile,
      filename: 'testfile.png',
      type: 'image/png',
    )
  end

  describe 'validation' do
    it 'requires content' do
      expect(described_class.new).not_to be_valid
      expect(change_request).to be_valid
    end
  end

  describe 'scopes and cleanup' do
    it 'finds open and old entries and removes old entries after create' do
      open_request = described_class.create!(content: { key: 'open' })
      done_request = described_class.create!(content: { key: 'done' }, done_at: 1.month.ago)
      old_request = described_class.create!(content: { key: 'old' })
      old_request.update_column(:done_at, 4.months.ago)

      expect(described_class.open).to eq [open_request]
      expect(described_class.old_entries).to eq [old_request]

      new_request = described_class.create!(content: { key: 'new' })
      expect(described_class.pluck(:id)).to contain_exactly(open_request.id, done_request.id, new_request.id)
    end
  end

  describe '#user' do
    it 'assigns api user or admin user' do
      expect(change_request.user).to be_nil

      change_request.user = api_user
      expect(change_request.api_user).to eq api_user
      expect(change_request.user).to eq api_user

      change_request.user = admin_user
      expect(change_request.admin_user).to eq admin_user
      expect(change_request.user).to eq admin_user

      change_request.user = 'something'
      expect(change_request.user).to eq admin_user
    end
  end

  describe '#content' do
    it 'returns deep symbolized hash' do
      expect(described_class.new.content).to eq({})
      change_request.save!
      expect(change_request.reload.content).to eq(key: 'foo', data: { bar: 1 })
    end
  end

  describe '#done=' do
    it 'sets done_at once and resets it' do
      Timecop.freeze(Time.zone.local(2020, 1, 2, 3, 4, 5)) do
        change_request.done = '1'
      end
      expect(change_request.done_at).to eq Time.zone.local(2020, 1, 2, 3, 4, 5)

      change_request.done = 1
      expect(change_request.done_at).to eq Time.zone.local(2020, 1, 2, 3, 4, 5)

      change_request.done = '0'
      expect(change_request.done_at).to be_nil

      change_request.done = '2'
      expect(change_request.done_at).to be_nil
    end
  end

  describe '#files' do
    it 'stores uploaded files as base64 and restores them' do
      expect(change_request.files).to eq []

      change_request.files = [http_uploaded_file, 'not a file']
      change_request.save!
      change_request.reload

      expect(change_request.files_data[:files].count).to eq 1
      file = change_request.files.first
      expect(file).to be_a(ChangeRequest::ChangeRequestFile)
      expect(file.filename).to eq 'testfile.png'
      expect(file.original_filename).to eq 'testfile.png'
      expect(file.content_type).to eq 'image/png'
      expect(file.read.b).to eq Rails.root.join('spec/fixtures/files/testfile.png').binread
      expect(file.to_h).to eq(
        filename: 'testfile.png',
        content_type: 'image/png',
        binary: change_request.files_data[:files].first[:binary],
      )
    end
  end

  describe 'ChangeRequestUploader' do
    let(:klass) do
      Class.new do
        include ChangeRequestUploader

        attr_accessor :image

        change_request_upload :image
      end
    end
    let(:model) { klass.new }

    before do
      change_request.files = [http_uploaded_file]
      change_request.save!
    end

    it 'assigns file from change request' do
      model.image_change_request = "#{change_request.id}-0"
      expect(model.image).to be_a(ChangeRequest::ChangeRequestFile)
      expect(model.image.original_filename).to eq 'testfile.png'
    end

    it 'ignores unknown change requests and files' do
      model.image_change_request = "#{change_request.id}-1"
      expect(model.image).to be_nil

      model.image_change_request = "#{change_request.id + 1}-0"
      expect(model.image).to be_nil
    end

    it 'remembers upload attributes' do
      expect(klass.instance_variable_get(:@change_request_upload_attributes)).to eq [:image]
    end

    it 'works with team logo' do
      team = build(:team)
      team.image_change_request = "#{change_request.id}-0"
      expect(team.image).to be_present
      expect(team.image.file.original_filename).to eq 'testfile.png'
    end
  end
end
