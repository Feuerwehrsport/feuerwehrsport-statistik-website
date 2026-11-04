# frozen_string_literal: true

require 'rails_helper'

describe Caching::Cache do
  let(:cache_dir) { Pathname.new(Dir.mktmpdir) }
  let(:cache) do
    allow_any_instance_of(described_class).to receive(:cache_path).and_return(cache_dir.join('file-cache'))
    described_class.send(:new)
  end
  let(:calls) { [] }

  before { allow(described_class).to receive(:instance) { cache } }
  after { FileUtils.rm_rf(cache_dir) }

  def fetch_value(key, value)
    described_class.fetch(key) do
      calls.push(key)
      value
    end
  end

  it 'creates cache directory' do
    cache
    expect(cache_dir.join('file-cache')).to be_directory
  end

  it 'uses default cache path in tmp' do
    expect(described_class.send(:new).cache_path).to eq Rails.root.join('tmp/file-cache')
  end

  context 'when caching is disabled in configuration' do
    it 'always yields' do
      expect(fetch_value('foo', 1)).to eq 1
      expect(fetch_value('foo', 2)).to eq 2
      expect(calls).to eq %w[foo foo]
    end
  end

  context 'when caching is enabled in configuration' do
    before { allow(Rails.configuration).to receive(:caching).and_return(true) }

    it 'caches values' do
      expect(fetch_value('foo', 1)).to eq 1
      expect(fetch_value('foo', 2)).to eq 1
      expect(fetch_value('bar', 3)).to eq 3
      expect(calls).to eq %w[foo bar]
    end

    it 'can be cleared' do
      fetch_value('foo', 1)
      described_class.clear
      expect(fetch_value('foo', 2)).to eq 2
    end

    it 'yields if cache files are missing' do
      allow(cache).to receive(:read_entry).and_raise(Errno::ENOENT)
      expect(fetch_value('foo', 1)).to eq 1
      expect(calls).to eq %w[foo]
    end

    describe '.disable' do
      it 'disables caching inside the block' do
        fetch_value('foo', 1)
        result = nil
        described_class.disable { result = fetch_value('foo', 2) }
        expect(result).to eq 2
        expect(described_class.caching).to be true
        expect(fetch_value('foo', 3)).to eq 1
      end

      it 'restores caching state on error' do
        expect { described_class.disable { raise ArgumentError } }.to raise_error(ArgumentError)
        expect(described_class.caching).to be true
      end

      it 'keeps disabled state when nested' do
        described_class.disable do
          described_class.disable { nil }
          expect(described_class.caching).to be false
        end
        expect(described_class.caching).to be true
      end
    end
  end
end
