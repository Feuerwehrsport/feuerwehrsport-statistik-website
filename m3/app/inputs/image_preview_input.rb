# frozen_string_literal: true

class ImagePreviewInput < FilePreviewInput
  def input(_wrapper_options = nil)
    version = input_html_options.delete(:preview_version)
    url = input_html_options.delete(:preview_url)
    out = ActiveSupport::SafeBuffer.new
    out << '<div class="imagepreview">'.html_safe
    if object.send("#{attribute_name}?") && !has_errors?
      image = object.send(attribute_name)
      version = :thumb if version.nil? && image.respond_to?(:thumb)
      version = :thumbnail if version.nil? && image.respond_to?(:thumbnail)
      url ||= image.tap { |o| break o.send(version) if version }.send('url')
      out << template.image_tag(url, class: 'imagepreview-image')
      out << js_buttons
      out << remove_file_on_save
    end
    out << @builder.hidden_field("#{attribute_name}_cache")
    out << '<div class="imagepreview-input-wrapper">'.html_safe
    out << @builder.file_field(attribute_name, input_html_options)
    out << '</div>'.html_safe
    out << '</div>'.html_safe
  end
end
