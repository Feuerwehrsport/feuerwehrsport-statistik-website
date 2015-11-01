class Discipline
  def self.group?(discipline)
    discipline.in? [:gs, :fs, :la]
  end
end