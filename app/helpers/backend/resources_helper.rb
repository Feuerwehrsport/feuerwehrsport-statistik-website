module Backend::ResourcesHelper
  def breadcrum
    items = [
      link_to("Administration", backend_root_path),
      link_to(resource_class.model_name.human(count: 0), action: :index),
    ]
    if action_name == "index"
      items.push(t("scaffold.index"))
    else
      items.push(link_to("##{params[:id]}", action: :show))
      items.push(t("scaffold.#{action_name}"))
    end
    render 'breadcrum', items: items
  end
end