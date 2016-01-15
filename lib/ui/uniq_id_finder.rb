module UI
  module UniqIDFinder
    def available_id(name)
      regular = name.to_s.parameterize.first(50)
      return regular if id_available?(regular)
      i = 1
      i += 1 while !id_available?("#{regular}-#{i}")
      "#{regular}-#{i}"
    end

    def id_available?(id)
      !elements.any? { |a| a.id == id }
    end
  end
end