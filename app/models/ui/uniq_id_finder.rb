# frozen_string_literal: true

module Ui::UniqIdFinder
  def available_id(name)
    regular = name.to_s.parameterize.first(50)
    return regular if id_available?(regular)

    i = 1
    i += 1 until id_available?("#{regular}-#{i}")
    "#{regular}-#{i}"
  end

  def id_available?(id)
    elements.none? { |a| a.id == id }
  end
end
