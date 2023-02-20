# frozen_string_literal: true

UI::CountTable = Struct.new(:view, :rows, :options, :columns, :data_fields, :footer_options, :footer_block) do
  def initialize(*args)
    super
    self.options ||= {}
    self.columns = []
    self.data_fields = []
    before_initialize if respond_to? :before_initialize
    yield self
    after_initialize if respond_to? :after_initialize
  end

  def col(column_head, column_key = nil, options = {}, &block)
    if column_key.is_a? Hash
      options = column_key
      column_key = nil
    end
    column_key = [column_key] unless column_key.is_a? Array
    column_key.compact!
    columns.push UI::Column.new(self, column_head, column_key, options, block)
  end

  def data(data_name, &block)
    data_fields.push(UI::DataField.new(data_name, block))
  end

  def row_data(row)
    data = {}
    data_fields.each do |field|
      data[field.name] = field.block.call(row)
    end
    data
  end

  def row_class(row = nil, &block)
    if block.present?
      @row_class_block = block
    elsif @row_class_block.present?
      @row_class_block.call(row)
    end
  end

  def headlines
    columns.map(&:name)
  end

  def footer(options = {}, &block)
    self.footer_options = options
    self.footer_block = block
  end

  UI::DataField = Struct.new(:name, :block)

  UI::Column = Struct.new(:count_table, :name, :keys, :options, :block) do
    def content(row)
      if keys.present?
        value = row
        keys.each { |key| value = value.try(key) }

        if options[:link_to].present?
          to = options[:link_to] == true ? row : row.try(options[:link_to])
          count_table.view.link_to(value, to)
        else
          value
        end
      elsif options[:helper_method].present?
        if options[:helper_method_options].present?
          count_table.view.send(options[:helper_method], row, options[:helper_method_options])
        else
          count_table.view.send(options[:helper_method], row)
        end
      elsif options[:haml]
        count_table.view.capture_haml(row, &block)
      else
        block.call(row)
      end
    end

    def th_options
      options[:th_options] || {}
    end

    def th_value
      th_options[:link_to] ? count_table.view.link_to(name, th_options[:link_to]) : name
    end
  end
end
