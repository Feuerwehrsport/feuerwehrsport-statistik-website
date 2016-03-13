class FroalaInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push('froala-text-area')
  end
end