class BLA::BadgeDecorator < AppDecorator
  decorates_association :person
  decorates_association :hl_score
  decorates_association :hb_score
  translates_collection_value :status

  def to_s
    "#{person}: #{status} #{year}"
  end

  def second_time
    Firesport::Time.second_time(time)
  end

  def second_hl_time
    Firesport::Time.second_time(hl_time)
  end

  def second_hb_time
    Firesport::Time.second_time(hb_time)
  end

  def second_current_hl_time
    Firesport::Time.second_time(current_hl_time)
  end

  def second_current_hb_time
    Firesport::Time.second_time(current_hb_time)
  end
end
