# frozen_string_literal: true

class M3::Form::Structure
  include Enumerable
  attr_reader :children

  def initialize(*children)
    super()
    @children = children
  end

  def each
    @children.each { |child| yield(child) if child.visible? }
  end

  def push(child)
    @children << child
  end

  def <<(child)
    push(child)
  end

  def permitted_fields(fields = [])
    each { |child| child.permitted_fields(fields) }
    fields
  end

  def sanitize(params, options = {})
    each { |child| child.sanitize(params, **options) }
  end

  def inputs(*args, &)
    node(Inputs, args, &)
  end

  def render(*args, &)
    node(Render, args, &)
  end

  def fields_for(*args, &)
    node(FieldsFor, args, &)
  end

  def input(*args)
    push(Input.new(*args))
  end

  def association(*args)
    push(Association.new(*args))
  end

  def hint(*args)
    push(Hint.new(*args))
  end

  # Displays a value within the form.
  #
  #   f.value :foo                # => value = object.foo, label = human_attribute_name
  #   f.value :foo, label: ''     # => empty, but space-using label
  #   f.value :foo, label: false  # => no label and no space used
  #   f.value :foo, label: nil    # => label falls back to human_attribute_name
  #
  #   f.value :foo, hint: ''      # => empty, but space-using hint
  #   f.value :foo, hint: false   # => no hint and no space used
  #   f.value :foo, hint: nil     # => hint falls back to t3
  #
  #   f.value :foo, value: 'val'  # => value = 'val'
  #   f.value :foo, value: proc{ 'val' } # => label = human_attribute_name
  def value(*args)
    push(Value.new(*args))
  end

  def permit(*args)
    push(Permit.new(*args))
  end

  private

  def node(node_class, args)
    children = @children
    node = node_class.new(*args)
    @children = node
    yield
    children << node
    @children = children
  end

  class Node < M3::Form::Structure
    attr_accessor :name

    def initialize(name, *children)
      @name = name
      super(*children)
    end

    def visible?
      @children.any?(&:visible?)
    end
  end

  class Inputs < Node
    attr_accessor :options

    def initialize(name, options = {}, *children)
      @options = options
      super(name, *children)
    end

    def permitted_fields(fields)
      fields.push(name) if options[:as].present? && !name.in?(fields)
      super(fields)
    end

    def sanitize(params, options = {})
      each { |child| child.sanitize(params, **options) }
    end
  end

  class Render < Node
    attr_accessor :options

    def initialize(options, *children)
      @options = options
      super('Render', *children)
    end

    def sanitize(params, options = {})
      each { |child| child.sanitize(params, **options) }
    end
  end

  class FieldsFor < Node
    attr_accessor :name, :object, :options

    def initialize(name, record_object = nil, options = {})
      @object = record_object
      @options = options
      super(name)
    end

    def permitted_fields(fields)
      key = :"#{name}_attributes"
      hash = fields.find { |field| field.is_a?(Hash) && field[key].present? }
      if hash.nil?
        hash = { key => [:id] }
        fields.push(hash)
      end
      each { |child| child.permitted_fields(hash[key]) }
    end

    def sanitize(params, resource_class:)
      return if options[:disable_sanitize]

      reflection = resource_class.reflections[name.to_s]
      if reflection
        if reflection.collection?
          each do |child|
            next if params["#{name}_attributes"].blank?

            params["#{name}_attributes"].each do |_key, attributes|
              child.sanitize(attributes, resource_class: reflection.klass)
            end
          end
        else
          each do |child|
            if params["#{name}_attributes"].present?
              child.sanitize(params["#{name}_attributes"], resource_class: reflection.klass)
            end
          end
        end
      else
        Rails.logger.fatal "fields_for without reflections: #{inspect}"
      end
    end
  end

  class Leaf
    attr_accessor :name, :options

    def initialize(name, options = {})
      @name = name
      @visible = options.extract!(:if)[:if]
      @visible = true if @visible.nil?
      @options = options
    end

    def each; end

    def visible?
      @visible
    end

    def permitted_fields(fields)
      [name, :"#{name}_cache", :"remove_#{name}", { name => [] }].each do |key|
        fields.push(key) unless key.in?(fields)
      end
    end

    def sanitize(params, options = {}); end
  end

  class Input < Leaf
    def sanitize(params, resource_class:)
      unless params[name].present? && params[name].is_a?(String) && (number_input? || number_column?(resource_class))
        return
      end

      params[name].tr!(',', '.')
    end

    def number_input?
      options[:as].present? && options[:as].in?(%i[number currency integer float])
    end

    def number_column?(resource_class)
      columns_hash(resource_class)[name.to_s].try(:type).in?(%i[integer float decimal number])
    end

    def columns_hash(resource_class)
      if resource_class.respond_to?(:columns_hash)
        resource_class.columns_hash
      else
        {}
      end
    end
  end

  class Association < Leaf
    def permitted_fields(fields)
      [name, :"#{name}_id", { "#{name.to_s.singularize}_ids": [] }].each do |key|
        fields.push(key) unless key.in?(fields)
      end
    end
  end

  class Hint < Leaf
    def permitted_fields(fields); end
  end

  class Value < Leaf
    def permitted_fields(fields); end

    def label(resource)
      label = options[:label]
      label = options[:label].call(resource) if label.is_a?(Proc)
      label = resource.class.human_attribute_name(name) if label.nil?
      label
    end

    def value(resource)
      value = options[:value]
      value = options[:value].call(decorated(resource)) if value.is_a?(Proc)
      value ||= decorated(resource).send(name)
      value
    end

    def hint(resource, context)
      hint = options[:hint]
      hint = options[:hint].call(resource) if hint.is_a?(Proc)
      hint = context.t3(name, scope: :hints, default: '').presence if hint.nil?
      hint
    end

    private

    def decorated(resource)
      ApplicationDecorator.try_to_decorate(resource)
    end
  end

  class Permit < Leaf
    def permitted_fields(fields)
      fields.push(name) unless name.in?(fields)
    end
  end
end
