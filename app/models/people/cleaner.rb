class People::Cleaner
  include M3::FormObject

  def people
    Person.unused
  end
end
