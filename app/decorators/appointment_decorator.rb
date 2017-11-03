class AppointmentDecorator < AppDecorator
  decorates_association :event
  decorates_association :place
  decorates_association :links

  localizes :dated_at

  delegate :to_s, to: :name

  def discipline_images(options = {})
    object.discipline_array.map do |discipline|
      discipline_image(discipline, options)
    end.join(' ').html_safe
  end

  def page_title
    "#{dated_at} #{name} - Wettkampftermin"
  end

  def change_log_to_s
    "#{dated_at} - #{place}"
  end
end
