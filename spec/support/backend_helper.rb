RSpec.shared_examples 'a backend resource controller' do |options|
  options ||= {}
  only = options.delete(:only) || %i[new create show edit update index destroy]

  let(:resource_name) { described_class.new.send(:resource_name) }
  let(:resource_class) { described_class.new.resource_class }
  let(:resource) { create(resource_name) }
  let(:resource_create_attributes) { resource_attributes }
  let(:resource_update_attributes) { resource_attributes }

  if only.include?(:new)
    describe 'GET new' do
      it 'shows new form' do
        get :new
        expect(response).to be_success
      end
    end
  end

  if only.include?(:create)
    describe 'POST create' do
      it 'creates new resource' do
        expect do
          post :create, resource_name => resource_create_attributes
          id = described_class.new.resource_class.order(id: :desc).pluck(:id).first
          expect(response).to redirect_to(action: :show, id: id), -> { controller.form_resource.errors.inspect }
        end.to change(resource_class, :count).by(1)
        expect_change_log(after: {}, log: "create-#{resource_class.name.parameterize}")
      end
    end
  end

  if only.include?(:show)
    describe 'GET show' do
      it 'returns resource' do
        get :show, id: resource.id
        expect(response).to be_success
      end
    end
  end

  if only.include?(:edit)
    describe 'GET edit' do
      it 'shows edit form' do
        get :edit, id: resource.id
        expect(response).to be_success
      end
    end
  end

  if only.include?(:update)
    describe 'PUT update' do
      subject { -> { put :update, :id => resource.id, resource_name => resource_update_attributes } }

      it 'update resource' do
        subject.call
        expect(response).to redirect_to(action: :show, id: resource.id), -> { controller.form_resource.errors.inspect }
        expect_change_log(before: {}, after: {}, log: "update-#{resource_class.name.parameterize}")
      end
    end
  end

  if only.include?(:index)
    describe 'GET index' do
      before { resource }
      it 'returns resources' do
        get :index
        expect(response).to be_success
      end
    end
  end

  if only.include?(:destroy)
    describe 'DELETE destroy' do
      before { resource }
      it 'deletes resource' do
        expect do
          delete :destroy, id: resource.id
          expect(response).to redirect_to action: :index
        end.to change(resource_class, :count).by(-1)
        expect_change_log(before: {}, log: "destroy-#{resource_class.name.parameterize}")
      end
    end
  end
end
