module API
  class PeopleController < BaseController
    include CRUD::IndexAction

    protected

    def resource_collection
      if params[:gender].present?
        super.gender(params[:gender])
      else
        super
      end
    end
  end
end
