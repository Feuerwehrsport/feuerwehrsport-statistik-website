# frozen_string_literal: true

class Ui::NavTab
  include Ui::UniqIdFinder
  attr_reader :tabs
  alias elements tabs

  def initialize
    @tabs = []
    yield self
  end

  def tab(name, &block)
    id = available_id(name)
    global_id = "tav-tab-#{id}"
    @tabs.push Ui::Tab.new(name, id, global_id, block)
  end

  Ui::Tab = Struct.new(:name, :id, :global_id, :block)
end
