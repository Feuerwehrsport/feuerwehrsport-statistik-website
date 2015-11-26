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
      url_options = options.slice(:controller).merge(action: action)
      if can?(action, resource)
        if action == :destroy
          action_item(type, action, t("scaffold.#{action}"), url_for(url_options.merge(id: resource.to_param)), method: 'delete', data: { confirm: t("scaffold.confirm_deletion") })
        elsif action == :index
          action_item(type, action, t("scaffold.#{action}"), url_for(url_options))
        else
          action_item(type, action, t("scaffold.#{action}"), url_for(url_options.merge(id: resource.to_param)))
        end
      end
    end

    def action_item(type, action, label, content, opts={})
      classes = type == :button ? "btn btn-default" : ""
      if action == view.action_name.to_sym && (options[:controller].nil? || view.controller_name == options[:controller])
        classes += " btn-info" 
      end
      @items[type].push(link_to(label, content, opts.merge(class: classes)))
    end
  end
end
