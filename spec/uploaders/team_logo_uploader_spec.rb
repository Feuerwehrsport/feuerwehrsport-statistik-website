# frozen_string_literal: true

require 'rails_helper'

describe TeamLogoUploader do
  let(:upload_root) { Dir.mktmpdir }
  let(:team) { create(:team) }
  let(:uploader) { described_class.new(team, :image) }

  before { allow_any_instance_of(described_class).to receive(:root).and_return(upload_root) }
  after { FileUtils.rm_rf(upload_root) }

  it 'stores in team directory' do
    expect(uploader.store_dir).to eq "uploads/teams/#{team.id}"
  end

  it 'allows only images' do
    pending 'Bug: extension_white_list wird von CarrierWave 3 ignoriert (heißt jetzt extension_allowlist)'
    text_file = Tempfile.new(['logo', '.txt'])
    text_file.write('no image')
    text_file.rewind

    expect { uploader.cache!(text_file) }.to raise_error(CarrierWave::IntegrityError)
  ensure
    text_file&.close!
  end

  it 'creates resized versions' do
    uploader.store!(File.open(Rails.root.join('spec/fixtures/files/testfile.png')))

    expect(uploader.path).to start_with File.join(upload_root, "uploads/teams/#{team.id}")
    expect(File).to exist(uploader.path)

    tile = MiniMagick::Image.open(uploader.tile.path)
    expect([tile.width, tile.height]).to eq [100, 100]
    thumb = MiniMagick::Image.open(uploader.thumb.path)
    expect([thumb.width, thumb.height]).to eq [24, 24]

    original = MiniMagick::Image.open(uploader.path)
    expect(original.width).to be <= 1000
    expect(original.height).to be <= 1000
  end
end
