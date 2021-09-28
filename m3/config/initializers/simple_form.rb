# frozen_string_literal: true

require_dependency 'simple_form/inputs/base'

class SimpleForm::FormBuilder < ActionView::Helpers::FormBuilder
  map_type :check_boxes_inline, to: CollectionCheckBoxesInlineInput
  map_type :radio_buttons_button_group, to: CollectionRadioButtonsButtonGroupInput
  map_type :radio_buttons_inline, to: CollectionRadioButtonsInlineInput
end

module SimpleForm::Inputs
  class Base
    # Lookup translations for the given namespace using I18n, based on controller
    # name. Lookup priority as follows:
    #
    #   t3.{controller_path}.{action}.{namespace}.{attribute}
    #   t3.{controller_path}.{namespace}.{attribute}
    #
    #  Namespace is used for :labels and :hints.
    #
    #  Model is the actual object name, for a @user object you'll have :user.
    #  Action is the action being rendered, usually :new or :edit.
    #  And attribute is the attribute itself, :name for example.
    def translate_from_namespace(namespace, _default = '')
      name = reflection_or_attribute_name
      model_names = lookup_model_names.dup
      if model_names.length > 1
        model_names.shift
        name = (model_names + [reflection_or_attribute_name]).join('/')
      end
      @builder.template.controller.t3(name, scope: namespace, default: '', action_scope: true).presence
    end
  end
end

module SimpleForm::Tags
  class CollectionRadioButtons < ActionView::Helpers::Tags::CollectionRadioButtons
    def render_collection
      is_radio_buttons_button_group = @options[:as] == :radio_buttons_button_group
      item_wrapper_tag = @options.fetch(:item_wrapper_tag, :span)
      item_wrapper_class = @options[:item_wrapper_class]

      @collection.map do |item|
        value = value_for_collection(item, @value_method)
        text  = value_for_collection(item, @text_method)
        default_html_options = default_html_options_for_collection(item, value)
        additional_html_options = option_html_attributes(item)

        rendered_item = yield item, value, text, default_html_options.merge(additional_html_options)

        if @options.fetch(:boolean_style, SimpleForm.boolean_style) == :nested
          label_options = default_html_options.slice(:index, :namespace)
          label_options['class'] = @options[:item_label_class]
          if is_radio_buttons_button_group
            if @options[:checked] && value.to_s == @options[:checked]
              active = 'active'
            elsif !@options[:checked] && value.to_s == object.send(@method_name)
              active = 'active'
            end
            label_options['class'] = [label_options['class'], @options[:item_wrapper_class], active].flatten.compact
          end
          rendered_item = @template_object.label(@object_name, sanitize_attribute_name(value), rendered_item,
                                                 label_options)
        end

        if item_wrapper_tag.present? && !is_radio_buttons_button_group
          @template_object.content_tag(item_wrapper_tag,
                                       rendered_item, class: item_wrapper_class)
        else
          rendered_item
        end
      end.join.html_safe # rubocop:disable Rails/OutputSafety
    end

    def wrap_rendered_collection(collection)
      wrapper_tag = @options[:collection_wrapper_tag]

      if wrapper_tag
        options = {}
        options[:class] = @options[:collection_wrapper_class]
        options.merge! @options[:collection_wrapper_options]
        @template_object.content_tag(wrapper_tag, collection, options)
      else
        collection
      end
    end
  end
end

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.
  config.wrappers :default, class: :input,
                            hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    ## Extensions enabled by default
    # Any of these extensions can be disabled for a
    # given input by passing: `f.input EXTENSION_NAME => false`.
    # You can make any of these extensions optional by
    # renaming `b.use` to `b.optional`.

    # Determines whether to use HTML5 (:email, :url, ...)
    # and required attributes
    b.use :html5

    # Calculates placeholders automatically from I18n
    # You can also pass a string as f.input placeholder: "Placeholder"
    b.use :placeholder

    ## Optional extensions
    # They are disabled unless you pass `f.input EXTENSION_NAME => true`
    # to the input. If so, they will retrieve the values from the model
    # if any exists. If you want to enable any of those
    # extensions by default, you can change `b.optional` to `b.use`.

    # Calculates maxlength from length validations for string inputs
    b.optional :maxlength

    # Calculates pattern from format validations for string inputs
    b.optional :pattern

    # Calculates min and max from length validations for numeric inputs
    b.optional :min_max

    # Calculates readonly automatically from readonly attributes
    b.optional :readonly

    ## Inputs
    b.use :label_input
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }

    ## full_messages_for
    # If you want to display the full error message for the attribute, you can
    # use the component :full_error, like:
    #
    # b.use :full_error, wrap_with: { tag: :span, class: :error }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  config.boolean_style = :nested

  # Default class for buttons
  config.button_class = 'btn'

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  # config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div

  # CSS class to add for error notification helper.
  config.error_notification_class = 'error_notification'

  # ID to add for error notification helper.
  # config.error_notification_id = nil

  # Series of attempts to detect a default label method for collection.
  config.collection_label_methods = %i[to_label to_s name title]

  # Series of attempts to detect a default value method for collection.
  # config.collection_value_methods = [ :id, :to_s ]

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  # config.collection_wrapper_tag = nil

  # You can define the class to use on all collection wrappers. Defaulting to none.
  # config.collection_wrapper_class = nil

  # You can wrap each item in a collection of radio/check boxes with a tag,
  # defaulting to :span.
  # config.item_wrapper_tag = :span

  # You can define a class to use in all item wrappers. Defaulting to none.
  # config.item_wrapper_class = nil

  # How the label text should be generated altogether with the required text.
  # config.label_text = lambda { |label, required, explicit_label| "#{required} #{label}" }

  # You can define the class to use on all labels. Default is nil.
  # config.label_class = nil

  # You can define the default class to be used on forms. Can be overriden
  # with `html: { :class }`. Defaulting to none.
  config.default_form_class = 'form-horizontal'

  # You can define which elements should obtain additional classes
  # config.generate_additional_classes_for = [:wrapper, :label, :input]

  # Whether attributes are required by default (or not). Default is true.
  # config.required_by_default = true

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = false

  # Collection of methods to detect if a file type was given.
  # config.file_methods = [ :mounted_as, :file?, :public_filename ]

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value.
  # config.input_mappings = { /count/ => :integer }

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper that will be used for all inputs with specified type.
  # config.wrapper_mappings = { string: :prepend }

  # Namespaces where SimpleForm should look for custom input classes that
  # override default inputs.
  # config.custom_inputs_namespaces << "CustomInputs"

  # Default priority for time_zone inputs.
  # config.time_zone_priority = nil

  # Default priority for country inputs.
  # config.country_priority = nil

  # When false, do not use translations for labels.
  # config.translate_labels = true

  # Automatically discover new inputs in Rails' autoload path.
  # config.inputs_discovery = true

  # Cache SimpleForm inputs discovery
  # config.cache_discovery = !Rails.env.development?

  # Default class for inputs
  # config.input_class = nil

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = 'checkbox'

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  # config.include_default_input_wrapper_class = true

  # Defines which i18n scope will be used in Simple Form.
  config.i18n_scope = 't3'
end
