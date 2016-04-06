class AppointmentDecorator < ApplicationDecorator
  include Indexable
  decorates_association :event
  decorates_association :place
  decorates_association :links
  index_columns :id, :name, :dated_at

  attr_accessor :current_user
  delegate :to_s, to: :name

  def discipline_images(options={})
    object.discipline_array.map do |discipline|
      discipline_image(discipline, options)
    end.join(" ").html_safe
  end
end
