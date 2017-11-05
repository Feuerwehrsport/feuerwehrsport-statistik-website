class API::GroupScoresController < API::BaseController
  api_actions :show, :update,
              change_log: true,
              default_form: [:team_id].push((1..7).map { |i| :"person_#{i}" })

  def person_participation
    assign_resource
    authorize!(:person_participation, resource)
    save_attributes_for_logging
    begin
      change_person_participations
      success(resource_modulized_name.to_sym => resource_update_object, resource_name: resource_modulized_name)
    rescue ActiveRecord::RecordInvalid => e
      failed(message: e.message)
    end
  end

  protected

  def change_person_participations
    GroupScore.transaction do
      changed = false
      (1..7).each do |position|
        next if resource_params["person_#{position}"].blank?
        participation = resource.person_participations.where(position: position).first_or_initialize
        participation.person = Person.find_by(id: resource_params["person_#{position}"])
        next unless participation.changed?
        if participation.person.nil?
          resource.person_participations.where(position: position).destroy_all
        else
          participation.save!
        end
        changed = true
      end
      if changed
        resource.reload
        perform_logging
        clean_cache_and_build_new
      end
    end
  end
end
