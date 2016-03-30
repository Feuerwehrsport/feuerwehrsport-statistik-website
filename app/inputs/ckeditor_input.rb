class CkeditorInput < SimpleForm::Inputs::TextInput
  def input_html_classes
    super.push 'ckeditor-area'
  end
end
