# frozen_string_literal: true
class UI::NavTab
  include UI::UniqIDFinder
  attr_reader :tabs
  alias elements tabs

  def initialize
    @tabs = []
    yield self
  end

  def tab(name, &block)
    id = available_id(name)
    global_id = "tav-tab-#{id}"
    @tabs.push UI::Tab.new(name, id, global_id, block)
  end

  UI::Tab = Struct.new(:name, :id, :global_id, :block)
end
