# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Backend::Bla::BadgeGenerators', login: :admin do
  it_behaves_like 'a backend resource controller', only: %i[new]
end
