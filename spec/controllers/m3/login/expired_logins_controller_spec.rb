# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::ExpiredLoginsController, website: :default do
  include_examples 'works like a expired logins controller'
end
