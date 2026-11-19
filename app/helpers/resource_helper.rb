# frozen_string_literal: true

module ResourceHelper
  def resource
    @resource ||= begin
      res = controller.send(:resource)
      if res && decorator_class
        decorator_class.decorate(res)
      else
        ApplicationDecorator.try_to_decorate(res)
      end
    end
  end

  def parent_resource
    @parent_resource ||= ApplicationDecorator.try_to_decorate(controller.send(:parent_resource))
  end

  def collection
    @collection ||= begin
      coll = controller.send(:collection)
      if coll && decorator_class
        decorator_class.decorate_collection(coll)
      else
        ApplicationDecorator.try_to_decorate(coll)
      end
    end
  end

  def can?(verb, resource)
    resource = resource.object if resource.is_a?(Draper::Decorator)
    super
  end

  def resource_form_for(resource, options = {}, &)
    resource = resource.object if resource.is_a?(Draper::Decorator)
    options[:url] = controller.instance_exec(&options[:url]) if options[:url].respond_to?(:call)
    options[:builder] = Ui::Form::FormBuilder
    options[:html] ||= {}
    if !options[:html].key?(:class) && options.key?(:wrapper)
      config.default_form_class = 'form-horizontal'
      form_class = options[:wrapper].to_s == 'vertical_form' ? 'form-vertical' : SimpleForm.default_form_class
      options[:html][:class] = [form_class, simple_form_css_class(resource, options)].compact
    end
    options[:html][:data] = controller.instance_exec(&options[:html][:data]) if options[:html][:data].respond_to?(:call)
    simple_form_for(resource, options, &)
  end

  # Returns a form for the current resource. Naming is based on resource_class,
  # so even if resource is different (e.g. a subclass), the normally expected
  # param key is used.
  def resource_form(options = {}, &)
    target_action = form_resource.new_record? ? :create : :update
    options[:url] = url_for(action: target_action) if options[:url].blank?
    options.reverse_merge!(as: resource_params_name)
    resource_form_for(form_resource, options, &)
  end

  def t3(keys, options = {})
    options[:scope] ||= :views
    controller.send(:t3, keys, options)
  end

  def ca_t(*keys)
    options = keys.extract_options!
    options[:default] ||= ''
    options[:action_scope] = true unless options.key?(:action_scope)
    keys = keys.first if keys.length == 1
    t3(keys, options).presence
  end

  def ca_title
    if resource && resource.persisted?
      resource_string = resource.to_s
      resource_string = truncate(resource_string, length: 70) unless resource_string.html_safe?
      t3(:title, action_scope: true, default: '').presence.try(:html_safe) || resource_string
    elsif resource && resource.new_record?
      t3(:title, action_scope: true, default: '').presence.try(:html_safe) ||
        ca_t('.actions.new_resource', name: resource_class.model_name.human)
    else
      t3(:title, action_scope: true, default: '').presence.try(:html_safe) ||
        resource_class.model_name.human(count: :many)
    end
  end

  def head_title
    t3(:head_title, action_scope: true, default: '').presence || 'Feuerwehrsport-Statistik'
  end

  def asset_exist?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end

  def export_format_list
    formats = index_export_formats
    render('index_export_list', formats:) if formats.present?
  end

  def body_classes
    bc = []
    controller_name = controller_path.parameterize.dasherize
    bc << "#{controller_name}-#{action_name}"
    bc << controller_name
    bc << action_name
    bc
  end

  def remote_index_table(url, &)
    tag.div('', data: { controller: 'remote-index-table', remote_index_table_url_value: url }, &)
  end

  def sortable_index_label(label, field_name: nil, param_name: :order, asc: false, desc: false)
    if label.is_a?(Symbol)
      field_name ||= label
      label = index_label(label)
    end
    current_direction = params[param_name]
    if !asc && !desc
      asc = current_direction.to_s == "#{field_name}_asc"
      desc = current_direction.to_s == "#{field_name}_desc"
    end
    icon_name = :'chevron-expand'
    icon_name = :'caret-down-fill' if asc
    icon_name = :'caret-up-fill' if desc
    sort_icon = icon(icon_name, css: 'sort-icon')
    url = current_path_with_query(param_name => "#{field_name}_asc")
    url = current_path_with_query(param_name => "#{field_name}_desc") if asc
    url = current_path_with_query(param_name => nil) if desc
    link_to(url, class: "is-sortable #{asc || desc ? 'is-sorted' : 'is-unsorted'}") do
      safe_join([sort_icon, label.to_s], ' ')
    end
  end

  # current path with changed query params (nil removes a param); always a local path, so params like host
  # cannot turn it into a link to another site
  def current_path_with_query(changes)
    query = request.query_parameters.merge(changes.stringify_keys).compact
    query.empty? ? request.path : "#{request.path}?#{query.to_query}"
  end

  def index_label(label)
    if label.is_a?(Symbol)
      fallback = label
      fallback = resource_class.human_attribute_name(label) if resource_class
      label = t3(label, scope: :index_table_headers, default: fallback)
      label = label.to_s.html_safe
    end
    label
  end

  def keep_filter_options(for_key:)
    inputs = ''
    if params[for_key].present? && params[for_key].is_a?(Hash)
      inputs += params[for_key].map { |key, value| hidden_field_tag("#{for_key}[#{key}]", value) }.join
    end
    (inputs + hidden_field_tag(:order, params[:order])).html_safe
  end

  def human_name(attr_name, model_or_class = resource_class)
    model_or_class = model_or_class.class unless model_or_class.is_a?(Class)
    model_or_class.human_attribute_name(attr_name)
  end
end
