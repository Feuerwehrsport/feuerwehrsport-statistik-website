class Registrations::CompetitionDecorator < AppDecorator
  decorates_association :people
  decorates_association :admin_user
  decorates_association :assessments

  localizes :open_at, :close_at, :date

  def to_s
    [name, date].join(' - ')
  end

  def discipline_images(options = {})
    object.discipline_array.map do |discipline|
      discipline_image(discipline, options)
    end.join(' ').html_safe
  end

  def slug_info
    h.render('slug_info')
  end
end
