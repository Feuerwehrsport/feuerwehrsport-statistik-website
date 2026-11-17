# frozen_string_literal: true

class WysiwygInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push 'ckeditor-area'
  end

  def input_html_options
    super.merge(data: { controller: 'ckeditor' })
  end
end
