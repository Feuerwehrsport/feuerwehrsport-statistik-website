# frozen_string_literal: true
require 'rails_helper'

RSpec.describe M3::Login::SessionsController, type: :controller, website: :default do
  include_examples 'works like a sessions controller' do
    let(:show_redirects_to_url) { backend_root_path }
  end
end
