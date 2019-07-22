require 'rails_helper'

RSpec.describe BLA::BadgesController, type: :controller do
  let!(:badge) { create(:bla_badge) }

  describe 'GET index' do
    it 'assigns collection' do
      get :index
      expect(response).to be_successful
      expect(controller.send(:collection).length).to eq 1
    end

    context 'when xlsx requested' do
      render_views
      it 'renders' do
        get :index, format: :xlsx
        expect(response).to be_successful
      end
    end
  end
end
