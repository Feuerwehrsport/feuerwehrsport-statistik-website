module CRUD::Accessor
  extend ActiveSupport::Concern

  protected

  class_methods do
    def implement_crud_actions(options = {})
      only = options[:only]
      only ||= [:index, :show]
      only = [only].flatten
      include CRUD::IndexAction if only.include?(:index)
      include CRUD::ShowAction if only.include?(:show)
    end
  end
end