# frozen_string_literal: true

def json_body
  JSON.parse(response.body, symbolize_names: true)
end

def expect_api_authorize_error
  expect_api_login_response(success: false, message: 'You are not authorized to access this page.')
end

def expect_json_response(hash = nil)
  expect(response.header['Content-Type']).to include 'application/json'
  expect(json_body).to eq hash if hash
end

def expect_api_login_response(hash = {})
  default_hash = { success: true, login: true, current_user: UserSerializer.new(login_user).serializable_hash }
  expect_json_response(default_hash.merge(hash))
end

def expect_api_not_login_response(hash = {})
  default_hash = { success: true, login: false }
  expect_json_response(default_hash.merge(hash))
end

RSpec.shared_examples 'api user get permission error' do
  context 'when user has no permissions', login: :api do
    it 'failes' do
      r.call
      expect_api_authorize_error
    end
  end
end

RSpec.shared_examples 'sub_admin get permission error' do
  context 'when user has no permissions', login: :sub_admin do
    it 'failes' do
      r.call
      expect_api_authorize_error
    end
  end
end
