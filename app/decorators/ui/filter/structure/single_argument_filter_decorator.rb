# frozen_string_literal: true

class Ui::Filter::Structure::SingleArgumentFilterDecorator < Ui::Filter::Structure::FilterDecorator
  def filter?
    argument.present?
  end

  def argument
    param.presence
  end
end
