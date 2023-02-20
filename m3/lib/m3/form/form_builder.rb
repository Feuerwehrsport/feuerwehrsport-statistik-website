# frozen_string_literal: true

require_dependency 'm3/form'

class M3::Form::FormBuilder < SimpleForm::FormBuilder
  def inputs(legend = nil, options = {}, &block)
    if legend.is_a?(Symbol)
      attribute_name = object.class.human_attribute_name(legend)
      legend = localize(:fieldsets, legend, default: attribute_name)
    end
    template.render('form_inputs', legend: legend, classes: options[:class], content: block)
  end

  def input(attribute_name, given_options = {}, &block)
    options      = given_options.dup
    column       = send(:find_attribute_column, attribute_name)
    input_type   = send(:default_input_type, attribute_name, column, options)
    inline_label = localize(:inline_labels, attribute_name)

    options[:label] = proc_to_value(options[:label], object)
    options.reverse_merge!(inline_label: inline_label) if inline_label.present?
    add_collection(attribute_name, options) if needs_collection?(options)
    options[:include_blank] = true if needs_blank?(input_type, options)
    super(attribute_name, options, &block)
  end

  def association(association, options = {}, &block)
    options = options.dup

    if block
      return simple_fields_for(*[association,
                                 options.delete(:collection), options].compact, &block)
    end

    raise ArgumentError, 'Association cannot be used in forms not associated with an object' unless @object

    reflection = find_association_reflection(association)
    raise "Association #{association.inspect} not found" unless reflection

    options[:as] ||= :select
    options[:collection] ||= reflection.polymorphic? ? [] : fetch_association_collection(reflection, options)
    decorate_collection(options)

    attribute = build_association_attribute(reflection, association, options)

    input(attribute, options.merge(reflection: reflection))
  end

  def actions(abort_url: true, submit_label: nil, abort_label: nil, &block)
    submit_label = template.controller.instance_exec(&submit_label) if submit_label.respond_to?(:call)
    @submit_label = submit_label
    abort_label = template.controller.instance_exec(&abort_label) if abort_label.respond_to?(:call)
    @abort_label = abort_label
    block = default_actions(abort_url: abort_url) unless block_given?
    template.render('form_actions', content: block, f: self, wrapper_name: options[:wrapper] ||
      SimpleForm.default_wrapper)
  end

  def default_actions(abort_url: true)
    abort_url = template.controller.instance_exec(&abort_url) if abort_url.respond_to?(:call)
    abort_url = default_abort_url if abort_url == true
    -> { template.render('form_default_actions', abort_url: abort_url, f: self) }
  end

  def m3_fields_for(record_name, record_object = nil, options = {}, &block)
    options[:builder] ||= self.class
    simple_fields_for(record_name, record_object, options, &block)
  end

  def submit_label
    @submit_label ||= begin
      action = :submit
      if object && object.respond_to?(:persisted?)
        action = object.persisted? ? :update : :create
      end
      template.t3(action, scope: :form_actions, model: model_name, action_scope: true)
    end
  end

  def abort_label
    @abort_label.presence || template.t3(:abort, scope: :form_actions, model: model_name, action_scope: true)
  end

  def model_name
    if object.respond_to?(:model_name)
      object.model_name.human
    else
      object_name.to_s.humanize
    end
  end

  private

  def proc_to_value(proc_or_value, *args)
    if proc_or_value.is_a?(Proc)
      proc_or_value.call(*args)
    else
      proc_or_value
    end
  end

  def needs_collection?(options)
    %i[check_boxes check_boxes_inline select radio_buttons radio_buttons_inline radio_buttons_button_group]
      .include?(options[:as]) && options[:collection].nil?
  end

  def needs_blank?(input_type, options)
    %i[date datetime time].include?(input_type) && options[:collection].nil?
  end

  def add_collection(attribute_name, options)
    collection = object.class.human_collection(attribute_name, default: '').presence
    collection = collection.invert if collection.is_a?(Hash)
    options[:collection] = collection
  end

  def decorate_collection(options)
    options[:collection] = ApplicationDecorator.try_to_decorate(options[:collection])
    options[:collection] = options[:collection].option_scope if options[:collection].respond_to?(:option_scope)
    options.merge!(label_method: :option_label) if options[:collection].first.try(:respond_to?, :option_label)
  end

  def localize(type, attribute_name, default: nil)
    return unless object.class.respond_to?(:lookup_ancestors)

    out = template.t3(attribute_name, scope: type, model: model_name, default: default).presence
    out.respond_to?(:html_safe) ? out.html_safe : out # rubocop:disable Rails/OutputSafety
  end

  def default_abort_url
    if object.respond_to?(:persisted?) && object.persisted?
      template.member_redirect_url
    else
      template.collection_redirect_url
    end
  end
end
