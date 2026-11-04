# frozen_string_literal: true

class TimeStringInput < SimpleForm::Inputs::StringInput
  def input_type
    :string
  end

  def input_html_options
    super.deep_merge(
      data: {
        constraint: 'time',
      },
    )
  end
end
