module Backend
  class PeopleController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:first_name, :last_name, :gender, :nation_id)
    end
  end
end