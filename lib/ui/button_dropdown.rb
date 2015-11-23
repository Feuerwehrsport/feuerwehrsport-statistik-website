module UI
  class ButtonDropdown < Struct.new(:view, :resource, :options)
    delegate :render, :can?, :t, :button_to, :url_for, :link_to, to: :view

    def to_s
      @items = { button: [], link: [] }
      [:index, :show, :edit, :destroy].each do |action|
        if options[:only].nil? || options[:only].include?(action)
          action_items(:button, action)
        elsif options[:links].present? && options[:links].include?(action)
          action_items(:link, action)
        end
      end
      return "" if @buttons.blank? and @items.blank?
      render("ui/button_dropdown", buttons: @items[:button], links: @items[:link], options: options)
    end

    def action_items(type, action)
      if can?(action, resource)
        if action == :destroy
          action_item(type, action, t("scaffold.#{action}"), url_for(id: resource.to_param, action: action), method: 'delete', data: { confirm: t("scaffold.confirm_deletion") })
        elsif action == :index
          action_item(type, action, t("scaffold.#{action}"), url_for(action: action))
        else
          action_item(type, action, t("scaffold.#{action}"), url_for(id: resource.to_param, action: action))
        end
      end
    end

    def action_item(type, action, label, content, options={})
      classes = type == :button ? "btn btn-default" : ""
      classes += " btn-info" if action == view.action_name.to_sym
      @items[type].push(link_to(label, content, options.merge(class: classes)))
    end
  end
end
