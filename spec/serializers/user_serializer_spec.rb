# frozen_string_literal: true

require 'rails_helper'
require_relative 'serializer_helper'

RSpec.describe UserSerializer do
  include SerializerSpecHelper

  let(:admin_user) { create(:admin_user, :admin) }
  let(:api_user) { create(:api_user) }

  it 'serializes plain user (used for current_user in api responses)' do
    expect(JSON.parse(described_class.new(admin_user).to_json, symbolize_names: true))
      .to eq(name: 'admin', type: 'admin-user')
    expect(JSON.parse(described_class.new(api_user).to_json, symbolize_names: true))
      .to eq(name: 'Api User', type: 'api-user')
  end

  describe AdminUserSerializer do
    it 'serializes admin user' do
      expect(api_json(admin_user)).to include(name: 'admin', named_email_address: 'admin <admin@example.com>')
      expect(api_json(admin_user).keys).to eq %i[name type named_email_address]
    end

    it 'serializes type without decorator suffix' do
      pending 'Bug: UserSerializer#type nutzt object.class -> bei dekorierten Objekten "admin-user-decorator"'
      expect(api_json(admin_user)[:type]).to eq 'admin-user'
    end

    it 'quotes special characters in display name' do
      admin_user.login.update!(name: 'Meier, Hans')
      expect(api_json(admin_user)[:named_email_address]).to eq '"Meier, Hans" <admin@example.com>'
    end
  end

  describe ApiUserSerializer do
    it 'serializes api user' do
      expect(api_json(api_user)).to include(name: 'Api User', named_email_address: 'Api User <api@user.de>')
      expect(api_json(api_user).keys).to eq %i[name type named_email_address]
    end

    it 'returns nil for missing email address' do
      api_user.update!(email_address: '')
      expect(api_json(api_user)[:named_email_address]).to be_nil
    end
  end
end
