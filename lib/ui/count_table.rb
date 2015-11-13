module UI
  class CountTable < Struct.new(:view, :rows, :options, :columns)
    def initialize(*args)
      super
      self.options ||= {}
      self.columns = []
      yield self
    end

    def col column_head, column_key=nil, options={}, &block
      if column_key.is_a? Hash
        options = column_key
        column_key = nil
      end
      column_key = [column_key] unless column_key.is_a? Array
      column_key.compact!
      columns.push Column.new(self, column_head, column_key, options, block)
    end

    def headlines
      columns.map(&:name)
    end

    class Column < Struct.new(:count_table, :name, :keys, :options, :block)
      def content row
        if keys.present?
          value = row
          keys.each { |key| value = value.try(key) }
          
          if options[:link_to].present?
            count_table.view.link_to(value, row.try(options[:link_to]))
          else
            value
          end
        elsif options[:helper_method].present?
          count_table.view.send(options[:helper_method], row)
        else
          block.call(row)
        end
      end

      def th_options
        options.slice(:title)
      end
    end
  end
end