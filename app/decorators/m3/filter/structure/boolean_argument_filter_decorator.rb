# frozen_string_literal: true

class M3::Filter::Structure::BooleanArgumentFilterDecorator < M3::Filter::Structure::FilterDecorator
  def filter?
    checked?
  end

  def checked?
    param.present? && param != '0'
  end
end
