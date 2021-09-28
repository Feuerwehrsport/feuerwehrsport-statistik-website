# frozen_string_literal: true

module M3::FindBySQL
  extend ActiveSupport::Concern

  class_methods do
    def connection
      ActiveRecord::Base.connection
    end

    def count_by_sql(sql)
      connection.select_value(sql, "#{name} Count").to_i
    end

    def find_by_sql(sql, binds = [])
      result_set = connection.select_all(sql, "#{name} Load", binds)
      result_set.map do |result|
        type_name = result.delete('type') || self
        type = type_name.constantize
        type.new(result)
      end
    end
  end
end
