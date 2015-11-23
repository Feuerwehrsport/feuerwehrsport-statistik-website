module Indexable
  extend ActiveSupport::Concern
  class_methods do
    def index_columns(*columns)
      if columns.count > 0
        @index_columns = columns
      else
        @index_columns
      end
    end
  end

  def index_columns
    self.class.index_columns
  end
end