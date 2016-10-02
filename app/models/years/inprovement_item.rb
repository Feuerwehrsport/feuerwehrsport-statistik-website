class Years::InprovementItem < Struct.new(:person)
  include Draper::Decoratable

  def current_scores
    @current_scores ||= []
  end

  def last_scores
    @last_scores ||= []
  end

  def <=>(other)
    other.difference <=> difference
  end

  def difference
    last_average - current_average
  end

  def last_average
    last_scores.count >= 3 ? last_scores.sort_by!(&:time).first(3).map(&:time).sum/3 : 99999999
  end

  def current_average
    current_scores.count >= 3 ? current_scores.sort_by!(&:time).first(3).map(&:time).sum/3 : 99999999
  end
end