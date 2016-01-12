module API
  class GroupScoresController < BaseController
    include CRUD::ShowAction
    include CRUD::UpdateAction
    before_action :assign_instance_for_person_participation, only: :person_participation
    
    def person_participation
      begin
        change_person_participations
        before_person_participation_success
      rescue ActiveRecord::RecordInvalid => e
        failed(message: e.message)
      end
    end

    protected

    def update_permitted_attributes
      permitted_attributes.permit(:team_id)
    end

    def assign_instance_for_person_participation
      assign_existing_instance
      self.resource_instance = resource_instance.decorate
    end

    def before_person_participation_success
      success(resource_variable_name.to_sym => resource_instance, resource_name: resource_variable_name)
    end

    def change_person_participations
      GroupScore.transaction do
        changed = false
        (1..7).each do |position|
          if permitted_attributes["person_#{position}"].present?
            participation = resource_instance.person_participations.where(position: position).first_or_initialize
            participation.person = Person.find_by_id(permitted_attributes["person_#{position}"])
            if participation.changed?
              if participation.person.nil?
                resource_instance.person_participations.where(position: position).destroy_all
              else
                participation.save!
              end
              changed = true
            end
          end
        end
        if changed
          # TODO: Logging
        end
      end
    end
  end
end
