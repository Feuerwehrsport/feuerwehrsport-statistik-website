# frozen_string_literal: true

RSpec.shared_examples 'a backend resource controller' do |options|
  options ||= {}
  only = options.delete(:only) || %i[new create show edit update index destroy]

  let(:resource_name) { controller_class.new.send(:resource_name) }
  let(:resource_class) { controller_class.new.send(:resource_class) }
  let(:resource) { create(resource_name) }
  let(:resource_create_attributes) { resource_attributes }
  let(:resource_update_attributes) { resource_attributes }
  let(:change_log_enabled) { true }
  let(:controller_class) do |ee|
    group = ee.metadata[:example_group]
    group = group[:parent_example_group] while group[:parent_example_group]
    "#{group[:description]}Controller".constantize
  end

  if only.include?(:new)
    describe 'GET new' do
      it 'shows new form' do |_ee|
        get url_for(controller: controller_class.controller_path, action: :new)
        expect(response).to be_successful
      end
    end
  end

  if only.include?(:create)
    describe 'POST create' do
      it 'creates new resource' do
        expect do
          post url_for(controller: controller_class.controller_path, action: :create),
               params: { resource_name => resource_create_attributes }
          id = resource_class.order(id: :desc).pick(:id)
          expect(response).to redirect_to(action: :show, id:), -> { controller.form_resource.errors.inspect }
        end.to change(resource_class, :count).by(1)
        expect_change_log(after: {}, log: "create-#{resource_class.name.parameterize}") if change_log_enabled
      end
    end
  end

  if only.include?(:show)
    describe 'GET show' do
      it 'returns resource' do
        get url_for(controller: controller_class.controller_path, action: :show, id: resource.id)
        expect(response).to be_successful
      end
    end
  end

  if only.include?(:edit)
    describe 'GET edit' do
      it 'shows edit form' do
        get url_for(controller: controller_class.controller_path, action: :edit, id: resource.id)
        expect(response).to be_successful
      end
    end
  end

  if only.include?(:update)
    describe 'PUT update' do
      let(:r) do
        -> {
          put url_for(controller: controller_class.controller_path, action: :update, id: resource.id),
              params: { resource_name => resource_update_attributes }
        }
      end

      it 'update resource' do
        r.call
        expect(response).to redirect_to(action: :show, id: resource.id), -> { controller.form_resource.errors.inspect }
        if change_log_enabled
          expect_change_log(before: {}, after: {}, log: "update-#{resource_class.name.parameterize}")
        end
      end
    end
  end

  if only.include?(:index)
    describe 'GET index' do
      before { resource }

      it 'returns resources' do
        get url_for(controller: controller_class.controller_path, action: :index)
        expect(response).to be_successful
      end
    end
  end

  if only.include?(:destroy)
    describe 'DELETE destroy' do
      before { resource }

      it 'deletes resource' do
        expect do
          delete url_for(controller: controller_class.controller_path, action: :destroy, id: resource.id)
          expect(response).to redirect_to action: :index
        end.to change(resource_class, :count).by(-1)
        expect_change_log(before: {}, log: "destroy-#{resource_class.name.parameterize}") if change_log_enabled
      end
    end
  end
end
