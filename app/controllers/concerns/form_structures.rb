# frozen_string_literal: true

module FormStructures
  extend ActiveSupport::Concern

  included do
    helper_method :m3_form_structure
    helper_method :m3_form_options
    class_attribute :m3_form_structure_hash
    class_attribute :m3_form_options_hash
    self.m3_form_structure_hash ||= {}
    self.m3_form_options_hash ||= {}
  end

  class_methods do
    def default_form(options = {}, &block)
      new_hash = m3_form_structure_hash.clone
      new_hash.default = block
      self.m3_form_structure_hash = new_hash
      new_options_hash = m3_form_options_hash.clone
      new_options_hash.default = options
      self.m3_form_options_hash = new_options_hash
    end

    def form_for(*action_names, &block)
      options = action_names.extract_options!
      new_hash = m3_form_structure_hash.clone
      new_options_hash = m3_form_options_hash.clone
      action_names.each do |action_name|
        new_hash[action_name.to_sym] = block
        new_options_hash[action_name.to_sym] = options
      end
      self.m3_form_structure_hash = new_hash
      self.m3_form_options_hash = new_options_hash
    end
  end

  protected

  def m3_form_structure
    f = M3::Form::Structure.new
    block = m3_form_structure_hash[action_name.to_sym]
    instance_exec(f, &block) if block.present?
    f
  end

  def m3_form_options
    opts = m3_form_options_hash[action_name.to_sym].clone
    opts[:html] = opts[:html].clone if opts.key?(:html)
    opts
  end

  def resource_params
    @resource_params ||= if m3_form_structure_hash[action_name.to_sym].present? && params.key?(resource_params_name)
                           permitted_params = params[resource_params_name].permit(
                             m3_form_structure.permitted_fields,
                           )
                           m3_form_structure.sanitize(permitted_params, resource_class:)
                           permitted_params
                         else
                           {}
                         end
  end
end
