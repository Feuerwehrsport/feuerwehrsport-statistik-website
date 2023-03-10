# frozen_string_literal: true

class M3::Filter::Structure
  include Enumerable
  include Draper::Decoratable

  def initialize(*children)
    @children = children
  end

  def each(&)
    @children.each(&)
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

    def string(name, options = {}, &)
      @parent << StringFilter.new(name, options, &)
    end

    def presence(name, options = {}, &)
      @parent << PresenceFilter.new(name, options, &)
    end

    def scope(name, options = {}, &)
      @parent << if options[:collection] && options[:as] == :check_boxes
                   ScopeWithCheckBoxesFilter.new(name, options, &)
                 elsif options[:collection]
                   ScopeWithSelectedArgumentFilter.new(name, options, &)
                 else
                   ScopeFilter.new(name, options, &)
                 end
    end

    def configurable(name, options = {}, &)
      @parent << ConfigurableFilter.new(name, options, &)
    end

    def date_lteq(name, options = {}, &)
      @parent << DateFilter.new(name, options.merge(operator: :lteq), &)
    end

    def date_gteq(name, options = {}, &)
      @parent << DateFilter.new(name, options.merge(operator: :gteq), &)
    end

    def date_lt(name, options = {}, &)
      @parent << DateFilter.new(name, options.merge(operator: :lt), &)
    end

    def date_gt(name, options = {}, &)
      @parent << DateFilter.new(name, options.merge(operator: :gt), &)
    end

    def date_eq(name, options = {}, &)
      @parent << DateFilter.new(name, options.merge(operator: :eq), &)
    end
  end
end
