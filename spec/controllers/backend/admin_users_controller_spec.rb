# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::AdminUsersController, type: :controller do
  context 'when admin user', login: :admin do
    it_behaves_like 'a backend resource controller', only: %i[show edit update index destroy] do
      let(:resource_attributes) { { name: 'New name', password: 'asdf' } }
    end
  end

  context 'when normal user', login: :user do
    it_behaves_like 'a backend resource controller', only: %i[show edit update] do
      let(:resource_attributes) { { name: 'New name' } }
      let(:resource) { login_user }
    end
  end
end
