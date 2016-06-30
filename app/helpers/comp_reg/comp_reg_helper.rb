module CompReg::CompRegHelper
  def breadcrum
    items = [ link_to("Wettkampfanmeldungen", comp_reg_competitions_path) ]

    if resource_instance.present? && resource_instance.respond_to?(:competition)
      items.push(link_to(resource_instance.competition.name, comp_reg_competition_path(resource_instance.competition)))
    end
    begin
      items.push(link_to(resource_class.model_name.human(count: 0), action: :index))
    rescue ActionController::UrlGenerationError
    end
    if action_name == "index"
      items.push(t("scaffold.index"))
    else
      items.push(link_to("##{params[:id]}", action: :show)) if params[:id].present?
      items.push(t("scaffold.#{action_name}"))
    end
    render 'breadcrum', items: items
  end

  def edit_participation(row, assessment)
    value = row.person_assessment_participations.find_by(competition_assessment: assessment).try(:decorate).try(:short_type)
    link = link_to(
      content_tag(:span, "", class: "glyphicon glyphicon-pencil"), 
      { action: :participations, controller: :people, id: row.id }, 
      { remote: true, class: "btn btn-default btn-xs pull-right" }
    )
    link = can?(:edit, row) ? link : ""
    "#{value.presence || "-"} #{link}".html_safe
  end
end