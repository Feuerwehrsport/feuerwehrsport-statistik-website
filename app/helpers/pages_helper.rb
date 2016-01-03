module PagesHelper
  def competition_find_link(id)
    competition_link(Competition.find(id).decorate)
  end

  def persons(ids, options={})
    ids = [ids] unless ids.is_a?(Array)
    ids.map { |id| person_link(Person.find(id).decorate, options) }.join(", ").html_safe
  end
end