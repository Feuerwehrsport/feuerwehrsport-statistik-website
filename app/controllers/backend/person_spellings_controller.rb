module Backend
  class PersonSpellingsController < ResourcesController
    protected

    def permitted_attributes
      super.permit(:first_name, :last_name, :gender, :person_id, :official)
    end
  end
end