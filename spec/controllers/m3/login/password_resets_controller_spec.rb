# frozen_string_literal: true

require 'rails_helper'

RSpec.describe M3::Login::PasswordResetsController, website: :default do
  include_examples 'works like a password resets controller'
end
