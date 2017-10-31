class BLA::BadgeDecorator < AppDecorator
  decorates_association :person
  decorates_association :hl_score
  decorates_association :hb_score
  translates_collection_value :status

  def to_s
    "#{person}: #{status} #{year}"
  end

  def second_time
    calculate_second_time(time)
  end

  def second_hl_time
    calculate_second_time(hl_time)
  end

  def second_hb_time
    calculate_second_time(hb_time)
  end
end
