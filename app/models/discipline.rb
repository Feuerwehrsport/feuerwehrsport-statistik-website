class Discipline
  PARTICIPATION_COUNT = {
    gs: 6,
    fs: 4,
    la: 7,
  }
  WITHOUT_DOUBLE_EVENT = [:hb, :hl, :gs, :fs, :la]
  ALL                  = [:hb, :hl, :zk, :gs, :fs, :la]
  def self.group?(discipline)
    discipline.in? [:gs, :fs, :la]
  end

  def self.participation_count(discipline)
    PARTICIPATION_COUNT[discipline]
  end
end