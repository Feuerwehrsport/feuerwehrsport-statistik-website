# frozen_string_literal: true

class YesNoInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input_type
    :radio_buttons
  end

  def input_html_classes
    super.push 'yes-no-input'
  end
end
