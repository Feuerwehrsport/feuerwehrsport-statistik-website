require 'rails_helper'

RSpec.describe API::Series::ParticipationsController, type: :controller do

  describe 'POST create' do
    let(:attributes) { { cup_id: "1", assessment_id: "1", person_id: "1", time: "1234", rank: "22", points: "22" } }
    subject { -> { post :create, series_participation: attributes } }
    it "creates new participation", login: :admin do
      expect {
        subject.call
        expect_api_login_response
      }.to change(Series::Participation, :count).by(1)
    end
    it_behaves_like "api user get permission error"
    it_behaves_like "sub_admin get permission error"
  end

  describe 'GET show' do
    subject { -> { get :show, id: 1 } }
    it "returns participation", login: :admin do
      subject.call
      expect_json_response
      expect(json_body[:series_participation]).to eq(
        id: 1, 
        points: 20, 
        rank: 1, 
        time: 1806, 
        second_time: "18,06", 
        person_id: 66,
        participation_type: "person",
        assessment_id: 1,
      )
    end
    it_behaves_like "api user get permission error"
    it_behaves_like "sub_admin get permission error"
  end

  describe 'PUT update' do
    let(:attributes) { { person_id: 1, time: 1234, rank: 22, points: 22 } }
    subject { -> { put :update, id: 1, series_participation: attributes } }
    it "updates participation", login: :admin do
      subject.call
      expect(json_body[:series_participation]).to include attributes
    end
    it_behaves_like "api user get permission error"
    it_behaves_like "sub_admin get permission error"
  end

  describe 'DELETE destroy' do
    subject { -> { delete :destroy, id: 1 } }
    it "destroys participation", login: :admin do
      expect {
        subject.call
        expect_json_response
      }.to change(Series::Participation, :count).by(-1)
    end
    it_behaves_like "api user get permission error"
    it_behaves_like "sub_admin get permission error"
  end
end