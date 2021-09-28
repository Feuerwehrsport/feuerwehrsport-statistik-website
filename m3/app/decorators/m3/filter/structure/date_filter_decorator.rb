# frozen_string_literal: true

class M3::Filter::Structure::DateFilterDecorator < M3::Filter::Structure::SingleArgumentFilterDecorator
  def filter_collection(collection, _resource_class)
    collection.where("#{name} #{sql_operator} ?", argument)
  end

  def sql_operator
    h = Hash.new('=')
    h[:lteq] = '<='
    h[:gteq] = '>='
    h[:lt] = '<'
    h[:gt] = '>'
    h[operator]
  end

  def argument
    super.to_date.to_s(:db)
  rescue StandardError
    nil
  end

  def inner_param_name
    "#{name}_#{operator}"
  end
end
