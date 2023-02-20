# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Backend::CompetitionFilesController, type: :controller, login: :sub_admin do
  let(:competition) { create(:competition) }

  it_behaves_like 'a backend resource controller' do
    let(:resource_attributes) do
      {
        competition_id: competition.id,
        file: fixture_file_upload('testfile.pdf', 'application/pdf'),
        keys_string: 'hb,hl',
      }
    end
  end
end
