# frozen_string_literal: true

shared_examples 'orders all index fields' do
  before { Dir[Rails.root.join('app/controllers/**/*_controller.rb')].each { |f| require_dependency f } }
  let(:controllers) { ApplicationController.descendants }
  let(:params_handler) { ->(params, _controller_instance) { params } }
  let(:collections) { {} }
  let(:directions) { %i[asc desc] }

  it 'orders all sortable index fields' do
    controllers.each do |controller|
      next if respond_to?(:exclude_controllers) && controller.in?(exclude_controllers)

      puts controller.name if respond_to?(:m3_index_structure_debug) && m3_index_structure_debug
      instance = controller.new
      next unless instance.respond_to?(:m3_index_structure)

      params = {}
      if instance.send(:parent_resource?)
        instance.send(:parent_resource=, parent_resources[controller])
        params[:"#{instance.parent_resource_name}_id"] = parent_resources[controller].to_param
      end
      params = params_handler.call(params, instance)

      request = ActionController::TestRequest.create(controller)
      request.assign_parameters(instance._routes, instance.controller_path, :index, params, '', %i[controller action])
      request.routes = instance._routes
      instance.request = request

      structure = instance.m3_index_structure
      resource_class = instance.send(:resource_class)
      collection = instance.send(:find_collection)
      collection = collections[controller].call(collection) if collections[controller].respond_to?(:call)

      structure.each do |field|
        next unless field.sortable?

        directions.each do |direction|
          allow(structure.h).to receive(:params).and_return(order: "#{field.name}_#{direction}")
          expect do
            structure.order_collection(collection, resource_class: resource_class).to_a
          end.to_not raise_error, "#{controller.name} field: #{field.name}"
        end
      end
    end
  end
end

shared_examples 'filter all fields' do
  before { Dir[Rails.root.join('app/controllers/**/*_controller.rb')].each { |f| require_dependency f } }
  let(:controllers) { ApplicationController.descendants }
  let(:params_handler) { ->(params, _controller_instance) { params } }
  it 'checks all controller filters' do
    controllers.each do |controller|
      next if respond_to?(:exclude_controllers) && controller.in?(exclude_controllers)

      instance = controller.new
      next unless instance.respond_to?(:m3_filter_structure)

      params = {}
      if instance.send(:parent_resource?)
        instance.send(:parent_resource=, parent_resources[controller])
        params[:"#{instance.parent_resource_name}_id"] = parent_resources[controller].to_param
      end
      params = params_handler.call(params, instance)

      request = ActionController::TestRequest.create(controller)
      request.assign_parameters(instance._routes, instance.controller_path, :index, params, '', %i[controller action])
      instance.request = request

      structure = instance.m3_filter_structure
      resource_class = instance.send(:resource_class)
      collection = instance.send(:find_collection)

      structure.each do |filter|
        allow(structure.h).to receive(:params).and_return(q: { filter.inner_param_name => '1' })
        if filter.options[:collection].is_a?(ActiveRecord::Relation)
          allow(filter.options[:collection]).to receive(:find_by!).and_return(filter.options[:collection].klass.new)
        end
        expect do
          structure.filter_collection(collection, resource_class: resource_class).to_a
        end.to_not raise_error, "#{controller.name} filter: #{filter.name}"
      end
    end
  end
end
