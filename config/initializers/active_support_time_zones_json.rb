# frozen_string_literal: true
class ActiveSupport::TimeWithZone
  def as_json(_options = {})
    strftime('%Y/%m/%d %H:%M:%S %z')
  end
end
