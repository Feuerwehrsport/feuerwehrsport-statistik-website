# frozen_string_literal: true

class M3::Filter::Structure::SingleArgumentFilterDecorator < M3::Filter::Structure::FilterDecorator
  def filter?
    argument.present?
  end

  def argument
    param.presence
  end
end
