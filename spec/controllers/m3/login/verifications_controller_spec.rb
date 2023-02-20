# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::VerificationsController, website: :default do
  include_examples 'works like a verification controller'
end
