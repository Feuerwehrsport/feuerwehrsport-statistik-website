module UI
  class CountTable
    attr_reader :columns, :rows, :options

    def initialize rows, options={}
      @rows = rows
      @options = options
      @columns = []
      yield self
    end

    def col column_head, column_key=nil, options={}, &block
      if column_key.is_a? Hash
        options = column_key
        column_key = nil
      end
      @columns.push Column.new(column_head, column_key, options, block)
    end

    def headlines
      @columns.map(&:name)
    end

    class Column < Struct.new(:name, :key, :options, :block)
      def content row
        if key.present?
          row.try(key)
        else
          block.call(row)
        end
      end
    end
  end
end