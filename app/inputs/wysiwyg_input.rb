# frozen_string_literal: true

# Rich text with Trix (trix_controller.js): a hidden field holds the HTML, the editor is bound to it.
class WysiwygInput < SimpleForm::Inputs::Base
  def input(wrapper_options = nil)
    options = merge_wrapper_options(input_html_options, wrapper_options)
    field_id = options[:id] || "#{object_name}_#{attribute_name}".parameterize(separator: '_')
    hidden = @builder.hidden_field(attribute_name, id: field_id)
    editor = template.content_tag('trix-editor', '', input: field_id, class: 'trix-content wysiwyg-editor',
                                                     'aria-label': object.class.human_attribute_name(attribute_name),
                                                     data: { controller: 'trix' })
    hidden + editor
  end
end
