# frozen_string_literal: true
Years::InprovementItem = Struct.new(:person, :year) do
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
    @last_average ||= best_x_average(last_scores, year == 2021 ? 2 : 3)
  end

  def current_average
    @current_average ||= best_x_average(current_scores, year == 2020 ? 2 : 3)
  end

  protected

  def best_x_average(scores, bext_x)
    scores.count >= bext_x ? scores.sort_by!(&:time).first(bext_x).map(&:time).sum / bext_x : Firesport::INVALID_TIME
  end
end
