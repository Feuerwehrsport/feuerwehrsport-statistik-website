class ScoreDoubleEventDecorator < ApplicationDecorator
  decorates_association :competition

  def second_time
    calculate_second_time(time)
  end
  
  def second_hb
    calculate_second_time(hb)
  end

  def second_hl
    calculate_second_time(hl)
  end
end
