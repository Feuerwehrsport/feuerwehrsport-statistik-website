# frozen_string_literal: true

class M3::Filter::Structure
  include Enumerable
  include Draper::Decoratable

  def initialize(*children)
    @children = children
  end

  def each(&block)
    @children.each(&block)
  end

  def <<(child)
    @children << child
  end

  def size
    @children.size
  end

  class Filter
    include Draper::Decoratable
    attr_accessor :name, :options, :block

    def initialize(name, options = {}, &block)
      @name    = name
      @options = options
      @block   = block
    end
  end

  class StringFilter < Filter
  end

  class PresenceFilter < Filter
  end

  class ScopeFilter < Filter
  end

  class ScopeWithSelectedArgumentFilter < Filter
  end

  class ScopeWithCheckBoxesFilter < Filter
  end

  class ConfigurableFilter < Filter
  end

  class DateFilter < Filter
    def operator
      options[:operator] || :eq
    end
  end

  class Builder
    attr_accessor :structure

    def initialize(structure = M3::Filter::Structure.new)
      @structure = structure
      @parent = structure
    end

    def string(name, options = {}, &block)
      @parent << StringFilter.new(name, options, &block)
    end

    def presence(name, options = {}, &block)
      @parent << PresenceFilter.new(name, options, &block)
    end

    def scope(name, options = {}, &block)
      @parent << if options[:collection] && options[:as] == :check_boxes
                   ScopeWithCheckBoxesFilter.new(name, options, &block)
                 elsif options[:collection]
                   ScopeWithSelectedArgumentFilter.new(name, options, &block)
                 else
                   ScopeFilter.new(name, options, &block)
                 end
    end

    def configurable(name, options = {}, &block)
      @parent << ConfigurableFilter.new(name, options, &block)
    end

    def date_lteq(name, options = {}, &block)
      @parent << DateFilter.new(name, options.merge(operator: :lteq), &block)
    end

    def date_gteq(name, options = {}, &block)
      @parent << DateFilter.new(name, options.merge(operator: :gteq), &block)
    end

    def date_lt(name, options = {}, &block)
      @parent << DateFilter.new(name, options.merge(operator: :lt), &block)
    end

    def date_gt(name, options = {}, &block)
      @parent << DateFilter.new(name, options.merge(operator: :gt), &block)
    end

    def date_eq(name, options = {}, &block)
      @parent << DateFilter.new(name, options.merge(operator: :eq), &block)
    end
  end
end
