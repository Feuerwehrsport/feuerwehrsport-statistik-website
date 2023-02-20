# frozen_string_literal: true

class AppointmentDecorator < AppDecorator
  decorates_association :event
  decorates_association :links

  localizes :dated_at

  delegate :to_s, to: :name

  def discipline_images(options = {})
    h.safe_join(object.discipline_array.map { |discipline| discipline_image(discipline, options) }, ' ')
  end

  def page_title
    "#{dated_at} #{name} - Wettkampftermin"
  end

  def change_log_to_s
    "#{dated_at} - #{place}"
  end

  def url
    h.appointment_url(self)
  end
end
