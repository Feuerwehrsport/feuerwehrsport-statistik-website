module UI
  class NavTab
    include UniqIDFinder
    attr_reader :tabs
    alias elements tabs

    def initialize
      @tabs = []
      yield self
    end

    def tab(name, &block)
      id = available_id(name)
      global_id = "tav-tab-#{id}"
      @tabs.push Tab.new(name, id, global_id, block)
    end

    class Tab < Struct.new(:name, :id, :global_id, :block)
    end
  end
end
