# frozen_string_literal: true

module ControllerTranslation
  extend ActiveSupport::Concern

  class_methods do
    def translation_paths
      paths = ancestors.map do |class_or_module|
        class_or_module.translation_path if class_or_module.respond_to?(:translation_path)
      end
      paths.compact
    end

    def translation_path
      controller_path
    end
  end

  def t3(key, options = {})
    options[:scope] ||= :controllers
    if key.is_a?(Enumerable)
      key.map do |k|
        t3(k, options)
      end
    else
      key = ".#{key}" unless key[0] == '.'
      t3_options = options.extract!(:action_scope, :scope)
      given_default = options[:default]
      scope = t3_options[:scope].present? ? ".#{t3_options[:scope]}" : ''
      controller_class = options.delete(:controller_class) || self.class
      controller_path = options.delete(:controller_path)
      controller_class = "#{controller_path}_controller".classify.constantize if controller_path.present?
      defaults = controller_class.translation_paths.map do |path|
        if t3_options[:action_scope]
          [:"t3.#{path}##{action_name}#{scope}#{key}", :"t3.#{path}#{scope}#{key}"]
        else
          [:"t3.#{path}#{scope}#{key}"]
        end
      end
      defaults.push(*[given_default].flatten)
      defaults.flatten!

      key = defaults.shift
      options[:default] = defaults
      @t3_interpolations ||= t3_interpolations
      options.reverse_merge!(t3_interpolations)

      out = I18n.t(key, **options)
      out = out.html_safe if out.is_a?(String) && key.to_s.end_with?('_html')
      out
    end
  end

  protected

  # A hash of interpolations used by +t3+.
  #
  # Be aware that this method can be used by all actions. Check if needed
  # resources are available before using them.
  #
  # Interpolations are cached after first call. Use +reload_t3_interpolations!+
  # if necessary.
  #
  # Use a Proc for calculation-heavy interpolations if you are not sure it will
  # be used.
  #
  #   def t3_interpolations
  #     if campaign
  #       { campaign: campaign.name, views: proc{ campaign.views.count } }
  #     else
  #       {}
  #     end
  #   end
  #
  #   title: Campaign %{campaign} (%{views} views)
  #
  #   t3(:title) # => Campaign RoR (20 views)
  def t3_interpolations
    {}
  end

  def reload_t3_interpolations!
    @t3_interpolations = t3_interpolations
  end
end
