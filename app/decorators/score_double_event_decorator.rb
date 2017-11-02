class ScoreDoubleEventDecorator < AppDecorator
  decorates_association :competition
  decorates_association :person

  def second_time
    Firesport::Time.second_time(time)
  end

  def second_hb
    Firesport::Time.second_time(hb)
  end

  def second_hl
    Firesport::Time.second_time(hl)
  end

  delegate :<=>, to: :object
end
