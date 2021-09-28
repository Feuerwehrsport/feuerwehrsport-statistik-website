# frozen_string_literal: true

class FilePreviewInput < SimpleForm::Inputs::FileInput
  def input(_wrapper_options = nil)
    input_html_options.delete(:preview_version)
    out = ActiveSupport::SafeBuffer.new
    if object.send("#{attribute_name}?") && !has_errors?
      file = object.send(attribute_name)
      out << template.tag.div(file.file.filename, class: 'imagepreview-filename')
      out << js_buttons
      out << remove_file_on_save
    end
    out << @builder.hidden_field("#{attribute_name}_cache")
    out << template.tag.div(@builder.file_field(attribute_name, input_html_options),
                            class: 'imagepreview-input-wrapper')
    template.tag.div(out, class: 'imagepreview')
  end

  protected

  def remove_file_on_save
    out = ActiveSupport::SafeBuffer.new
    label = template.tag.label(template.safe_join(
                                 [@builder.check_box("remove_#{attribute_name}", class: 'imagepreview-remove'),
                                  translations[:remove_file_on_save]], ' '
                               ))
    out << template.tag.div(label, class: 'checkbox')
    out << template.tag.div(translations[:will_be_removed], class: 'imagepreview-remove-hint')
  end

  def js_buttons
    buttons = [
      template.tag.button(translations[:edit], type: 'button', class: 'imagepreview-actions-edit'),
      template.tag.button(translations[:remove], type: 'button', class: 'imagepreview-actions-remove'),
      template.tag.button(translations[:reset], type: 'button', class: 'imagepreview-actions-reset'),
    ]
    template.tag.div(template.safe_join(buttons), class: 'imagepreview-actions')
  end

  def translations
    @translations ||= template.t3('image_preview_input')
  end
end
