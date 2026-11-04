# frozen_string_literal: true

require 'rails_helper'

describe Caching::CacheSupport do
  let(:public_dir) { Pathname.new(Dir.mktmpdir) }
  let(:controller_class) do
    Class.new(ApplicationController) do
      cache_actions :index, :show

      def self.name
        'CacheSupportTestController'
      end
    end
  end
  let(:path) { '/competitions/12' }
  let(:format) { 'text/html' }
  let(:action) { 'show' }
  let(:controller) do
    controller_class.new.tap do |c|
      c.request = ActionDispatch::TestRequest.create(
        'PATH_INFO' => path, 'HTTP_HOST' => 'test.host', 'HTTP_ACCEPT' => format,
      )
      c.response = ActionDispatch::TestResponse.new
      c.response.body = 'html content'
      c.response.content_type = format
      c.action_name = action
    end
  end

  before { allow(Rails).to receive(:public_path).and_return(public_dir) }
  after { FileUtils.rm_rf(public_dir) }

  describe '.cache_action?' do
    it 'checks configured actions' do
      expect(controller_class.cache_action?('index')).to be true
      expect(controller_class.cache_action?(:show)).to be true
      expect(controller_class.cache_action?('edit')).to be false
      expect(Class.new(ApplicationController).cache_action?(:index)).to be false
    end
  end

  describe '#save_html_cache' do
    it 'does nothing if caching is disabled' do
      controller.send(:save_html_cache)
      expect(public_dir.join('cache')).not_to exist
    end

    context 'when caching is enabled' do
      before { allow(Rails.configuration).to receive(:caching).and_return(true) }

      it 'writes response to public cache' do
        expect(controller.send(:save_html_cache?)).to be true
        controller.send(:save_html_cache)
        expect(public_dir.join('cache/competitions/12.html').read).to eq 'html content'
      end

      context 'with root path' do
        let(:path) { '/' }

        it 'writes index file' do
          controller.send(:save_html_cache)
          expect(public_dir.join('cache/_index.html').read).to eq 'html content'
        end
      end

      context 'with not cached action' do
        let(:action) { 'edit' }

        it 'does nothing' do
          controller.send(:save_html_cache)
          expect(public_dir.join('cache')).not_to exist
        end
      end

      context 'with json format' do
        let(:format) { 'application/json' }

        it 'does nothing' do
          expect(controller.send(:save_html_cache?, content_type: 'application/json')).to be false
          controller.send(:save_html_cache)
          expect(public_dir.join('cache')).not_to exist
        end
      end
    end
  end

  describe '#clean_cache_and_build_new' do
    it 'uses cleaner' do
      cleaner = instance_double(Caching::Cleaner, save: true)
      allow(Caching::Cleaner).to receive(:new).and_return(cleaner)
      controller.send(:clean_cache_and_build_new)
      expect(cleaner).to have_received(:save)
    end
  end
end
