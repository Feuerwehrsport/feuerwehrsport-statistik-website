# frozen_string_literal: true

class CollectionRadioButtonsInlineInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input_type
    :radio_buttons
  end

  def item_wrapper_class
    'radio-inline'
  end
end
