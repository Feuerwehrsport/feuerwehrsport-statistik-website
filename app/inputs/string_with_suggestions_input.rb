# frozen_string_literal: true

class StringWithSuggestionsInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    raise ArgumentError, 'StringWithSuggestionsInput requires a suggestions array' if suggestions.nil?

    @input_html_options[:list] = datalist_id
    @input_html_options[:autocomplete] = 'off'
    template.safe_join([super, suggestion_list])
  end

  private

  def suggestion_list
    options = suggestions.map do |suggestion|
      template.tag.option(suggestion)
    end
    template.tag.datalist(template.safe_join(options), id: datalist_id)
  end

  def suggestions
    options[:suggestions]
  end

  def datalist_id
    "#{attribute_name}_datalist"
  end
end
