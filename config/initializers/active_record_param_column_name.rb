# frozen_string_literal: true

class ActiveRecord::Base
  class << self
    def param_column_name
      :id
    end
  end
end
