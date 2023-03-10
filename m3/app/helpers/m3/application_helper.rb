# frozen_string_literal: true

require_dependency 'm3/index/structure'
require_dependency 'm3/form/structure'
require_dependency 'm3/form/form_builder'
require_dependency 'm3/filter/structure'

module M3::ApplicationHelper
  def resource
    @decorated_resource ||= begin
      res = controller.send(:resource)
      if res && decorator_class
        decorator_class.decorate(res)
      else
        ApplicationDecorator.try_to_decorate(res)
      end
    end
  end

  def parent_resource
    @decorated_parent_resource ||= ApplicationDecorator.try_to_decorate(controller.send(:parent_resource))
  end

  def collection
    @decorated_collection ||= begin
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
    super(verb, resource)
  end

  def m3_form_for(resource, options = {}, &)
    resource = resource.object if resource.is_a?(Draper::Decorator)
    options[:url] = controller.instance_exec(&options[:url]) if options[:url].respond_to?(:call)
    options[:builder] = M3::Form::FormBuilder
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
  def m3_form(options = {}, &)
    target_action = form_resource.new_record? ? :create : :update
    options[:url] = url_for(action: target_action) if options[:url].blank?
    options.reverse_merge!(as: resource_params_name)
    m3_form_for(form_resource, options, &)
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

  def m3_export_format_list
    formats = m3_index_export_formats
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
    tag.div('', data: { remote_index_table: url }, &)
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
    class_name = 'fa-sort'
    class_name = 'fa-sort-down' if asc
    class_name = 'fa-sort-up' if desc
    icon = tag.i('', class: "fa sort-icon #{class_name}")
    url = url_for(params.permit!.merge(param_name => "#{field_name}_asc"))
    url = url_for(params.permit!.merge(param_name => "#{field_name}_desc")) if asc
    url = url_for(params.permit!.merge(param_name => nil)) if desc
    link_to(url, class: "is-sortable #{asc || desc ? 'is-sorted' : 'is-unsorted'}") do
      icon << ' ' << label.to_s
    end
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

  def tracking_code
    code = []
    code.push(facebook_pixel_code) if facebook_pixel_id.present?
    code.push(google_analytics_code) if google_analytics_key.present?
    code.push(google_tag_manager_code) if google_tag_manager_key.present?
    code.push(@custom_tracking_code) if @custom_tracking_code.present?
    code.join.html_safe
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

  private

  def facebook_pixel_code
    <<~HTML
      <script>
        !function(f,b,e,v,n,t,s){if(f.fbq)return;n=f.fbq=function(){n.callMethod?
        n.callMethod.apply(n,arguments):n.queue.push(arguments)};if(!f._fbq)f._fbq=n;
        n.push=n;n.loaded=!0;n.version='2.0';n.queue=[];t=b.createElement(e);t.async=!0;
        t.src=v;s=b.getElementsByTagName(e)[0];s.parentNode.insertBefore(t,s)}(window,
          document,'script','https://connect.facebook.net/en_US/fbevents.js');
        fbq('init', '#{facebook_pixel_id}');
        fbq('track', 'PageView');
      </script>
      <noscript><img height='1' width='1' style='display:none' src='https://www.facebook.com/tr?id=#{facebook_pixel_id}&ev=PageView&noscript=1' /></noscript>
    HTML
  end

  def google_analytics_code
    <<~HTML
      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
        ga('create', '#{google_analytics_key}', 'auto');
        M3.ready(function() { ga('send', 'pageview'); });
      </script>
    HTML
  end

  def google_tag_manager_code
    <<~HTML
      <noscript><iframe src='//www.googletagmanager.com/ns.html?id=#{google_tag_manager_key}' height='0' width='0' style='display:none;visibility:hidden'></iframe></noscript>
      <script>window.dataLayer=[];(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});
        var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';
        j.async=true;j.src='//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})
        (window,document,'script','dataLayer','#{google_tag_manager_key}');
        M3.ready(function(){window.dataLayer.push({'event':'pageview','virtualUrl':window.location.pathname});})
      </script>
    HTML
  end
end
