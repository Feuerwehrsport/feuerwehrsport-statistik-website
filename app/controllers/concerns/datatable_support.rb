module DatatableSupport
  extend ActiveSupport::Concern

  included do
    class_attribute :datatables
    self.datatables = {}.with_indifferent_access
    helper_method :datatables
  end

  class_methods do
    def datatable(action_name, key, klass, options = {}, &block)
      datatables[action_name] ||= {}
      datatables[action_name][key] = structure = Datatables::Structure.build(self, klass: klass, &block).decorate

      before_action(only: action_name) do
        if request.format.json? && params[:datatable].to_sym == key
          collection = options[:collection] || klass.all.order(:id)
          collection = collection.call if collection.respond_to?(:call)
          count = collection.count

          collection = structure.search(collection, params[:search][:value])
          filter_count = collection.count

          page = (params[:start].to_i / params[:length].to_i) + 1
          structure.each_with_index do |field, index|
            break unless params[:order].is_a?(ActionController::Parameters)

            params[:order] = "#{field.name}_#{params[:order]['0'][:dir]}" if params[:order]['0'][:column].to_i == index
          end
          collection = structure.order_collection(collection, resource_class: klass)
          collection = collection.paginate(page: page, per_page: params[:length].to_i)
          render json: {
            draw: params[:draw].to_i,
            recordsTotal: count,
            recordsFiltered: filter_count,
            data: collection.decorate.map { |r| structure.map { |field| field.value(r) } },
          }
        end
      end
    end
  end
end
