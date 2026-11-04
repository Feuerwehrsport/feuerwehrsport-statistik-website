# frozen_string_literal: true

class CollectionRadioButtonsButtonGroupInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def apply_default_collection_options!(options)
    super
    options[:collection_wrapper_tag] = :div
    options[:collection_wrapper_class] = [options[:collection_wrapper_class], 'btn-group'].flatten.compact
    options[:collection_wrapper_options] = { 'data-toggle': 'buttons' }
  end

  def input_type
    :radio_buttons
  end

  def item_wrapper_class
    %w[btn btn-default]
  end
end
