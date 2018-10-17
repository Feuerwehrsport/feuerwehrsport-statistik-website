require 'rails_helper'

RSpec.describe API::PeopleController, type: :controller do
  let!(:nation) { create(:nation) }
  let(:person) { create(:person) }

  describe 'POST create' do
    it 'creates new person', login: :api do
      expect do
        post :create, person: { first_name: 'Alfred', last_name: 'Meier', gender: 'male', nation_id: nation.id }
        expect_api_login_response(created_id: Person.last.id)
      end.to change(Person, :count).by(1)
      expect_change_log(after: { gender: 'male' }, log: 'create-person')
    end
  end

  describe 'GET show' do
    it 'returns person' do
      get :show, id: person.id
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: 'Alfred',
        gender: 'male',
        id: person.id,
        last_name: 'Meier',
        nation_id: 1,
        gender_translated: 'männlich',
      )
    end
  end

  describe 'GET index' do
    before { person }

    let!(:female_person) { create(:person, :female) }

    it 'returns people' do
      get :index
      expect_json_response
      expect(json_body[:people].count).to eq 2
      expect(json_body[:people]).to match_array([
                                                  {
                                                    first_name: 'Alfred',
                                                    gender: 'male',
                                                    id: person.id,
                                                    last_name: 'Meier',
                                                    nation_id: 1,
                                                    gender_translated: 'männlich',
                                                  }, {
                                                    first_name: 'Johanna',
                                                    gender: 'female',
                                                    id: female_person.id,
                                                    last_name: 'Meyer',
                                                    nation_id: 1,
                                                    gender_translated: 'weiblich',
                                                  }
                                                ])
    end

    it 'returns only gendered people' do
      get :index, gender: :male
      expect_json_response
      expect(json_body[:people].count).to eq 1
      expect(json_body[:people].first).to eq(
        first_name: 'Alfred',
        gender: 'male',
        id: person.id,
        last_name: 'Meier',
        nation_id: 1,
        gender_translated: 'männlich',
      )
    end
  end

  describe 'PUT update' do
    subject { -> { put :update, id: person.id, person: { first_name: 'Vorname', last_name: 'Nachname', nation_id: nation.id } } }

    it 'update person', login: :sub_admin do
      subject.call
      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: 'Vorname',
        gender: 'male',
        id: person.id,
        last_name: 'Nachname',
        nation_id: 1,
        gender_translated: 'männlich',
      )
      expect_change_log(before: { gender: 'male' }, after: { first_name: 'Vorname' }, log: 'update-person')
    end
    it_behaves_like 'api user get permission error'
  end

  describe 'POST merge' do
    subject { -> { put :merge, id: person.id, correct_person_id: correct_person.id, always: 1 } }

    let!(:correct_person) { create(:person, first_name: 'Alfredo', last_name: 'Mayer') }

    it 'merge two people', login: :sub_admin do
      expect_any_instance_of(Person).to receive(:merge_to).and_call_original
      expect do
        subject.call
      end.to change(PersonSpelling, :count).by(1)

      expect_json_response
      expect(json_body[:person]).to eq(
        first_name: 'Alfredo',
        gender: 'male',
        id: correct_person.id,
        last_name: 'Mayer',
        nation_id: 1,
        gender_translated: 'männlich',
      )
      expect_change_log(before: { gender: 'male' }, after: { first_name: 'Alfredo' }, log: 'merge-person')
    end

    it 'creates entity_merge', login: :sub_admin do
      expect do
        subject.call
      end.to change(EntityMerge, :count).by(1)
    end
    it_behaves_like 'api user get permission error'
  end
end
