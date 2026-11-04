# frozen_string_literal: true

class Ui::Filter::Structure::BooleanArgumentFilterDecorator < Ui::Filter::Structure::FilterDecorator
  def filter?
    checked?
  end

  def checked?
    param.present? && param != '0'
  end
end
