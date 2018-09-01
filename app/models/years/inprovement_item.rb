Years::InprovementItem = Struct.new(:person) do
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
    @last_average ||= best_3_average(last_scores)
  end

  def current_average
    @current_average ||= best_3_average(current_scores)
  end

  protected

  def best_3_average(scores)
    scores.count >= 3 ? scores.sort_by!(&:time).first(3).map(&:time).sum / 3 : Firesport::INVALID_TIME
  end
end
