module CompReg
  class CompetitionsController < CompRegController
    include CRUD::NewAction
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::EditAction
    include CRUD::UpdateAction

    protected

    def permitted_attributes
      super.permit(:name, :place, :date)
    end

    def build_instance
      resource_class.new(admin_user: current_admin_user)
    end
  end
end
