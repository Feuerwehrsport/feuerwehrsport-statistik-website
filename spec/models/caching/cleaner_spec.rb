# frozen_string_literal: true

require 'rails_helper'

describe Caching::Cleaner do
  let(:public_dir) { Pathname.new(Dir.mktmpdir) }

  before do
    allow(Rails).to receive(:public_path).and_return(public_dir)
    FileUtils.mkdir_p(public_dir.join('cache/foo'))
    File.write(public_dir.join('cache/foo/index.html'), 'html')
    allow(Caching::Cache).to receive(:clear)
  end

  after { FileUtils.rm_rf(public_dir) }

  it 'removes html cache and clears file cache without rebuild' do
    expect { expect(described_class.new.save).to be true }.not_to have_enqueued_job
    expect(public_dir.join('cache')).not_to exist
    expect(public_dir).to exist
    expect(Caching::Cache).to have_received(:clear)
  end

  it 'works without existing cache' do
    FileUtils.rm_rf(public_dir.join('cache'))
    allow(Caching::Cache).to receive(:clear).and_raise(Errno::ENOENT)
    expect(described_class.new.save).to be true
  end

  context 'when caching is enabled' do
    before { allow(Rails.configuration).to receive(:caching).and_return(true) }

    it 'schedules rebuild jobs' do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 12, 0, 0)) do
        expect { described_class.new.save }
          .to have_enqueued_job(Caching::Builder).at(Time.zone.local(2020, 1, 1, 12, 5, 0))
          .and have_enqueued_job(Caching::HeavyBuilder).at(Time.zone.local(2020, 1, 1, 12, 10, 0))
      end
    end
  end
end
