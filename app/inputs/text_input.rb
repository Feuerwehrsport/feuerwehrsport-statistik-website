# frozen_string_literal: true

# textareas grow with their content (stimulus autosize)
class TextInput < SimpleForm::Inputs::TextInput
  def input_html_options
    super.merge(data: { controller: 'autosize', action: 'input->autosize#resize' })
  end
end
