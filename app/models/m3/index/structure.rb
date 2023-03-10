# frozen_string_literal: true

class M3::Index::Structure
  include Enumerable
  include Draper::Decoratable
  attr_accessor :edit_sheet_block, :options, :field_options

  def self.build(controller_instance, options = {}, &block)
    instance = new
    instance.field_options = options.delete(:field_options) || {}
    instance.options = options
    controller_instance.instance_exec(instance, &block) if block.present?
    instance
  end

  def initialize(children = [])
    @children = children
  end

  def col(name, options = {}, &)
    push(Field.new(name, field_options.merge(options), &))
  end

  def each
    @children.each { |child| yield(child) if child.visible? }
  end

  def <<(child)
    push(child)
  end

  def push(child)
    @children << child
    child.priority ||= [@children.length, 5].min
  end

  def field_names
    map(&:field_names).flatten
  end

  def edit_sheet(sheet = nil, &block)
    if block.present?
      self.edit_sheet_block = block
    elsif edit_sheet_block.respond_to?(:call)
      edit_sheet_block.call(sheet)
    end
  end

  class Field
    include Draper::Decoratable
    attr_accessor :name, :priority, :stringify_relation, :truncate, :options, :block

    def initialize(name, options = {}, &block)
      @name          = name
      @block         = block
      @visible       = options.delete(:if)
      @visible       = true if @visible.nil?
      @sortable      = options.delete(:sortable)
      @sortable      = name if @sortable.nil? || @sortable.is_a?(TrueClass)
      @default_order = options.delete(:default_order)
      @priority      = options.delete(:priority)
      @truncate      = options.delete(:truncate)
      @truncate      = 30 if @truncate.nil?
      @options       = options
    end

    def each; end

    def visible?
      @visible
    end

    def sortable?
      @sortable.present?
    end

    def sort_field
      @sortable
    end

    attr_reader :default_order

    def field_names
      [name]
    end
  end
end
