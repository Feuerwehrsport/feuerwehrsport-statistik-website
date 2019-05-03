class Registrations::CompetitionDecorator < AppDecorator
  decorates_association :people
  decorates_association :admin_user
  decorates_association :assessments
  decorates_association :teams

  localizes :open_at, :close_at, :date

  def to_s
    [name, date].join(' - ')
  end

  def discipline_images(options = {})
    h.safe_join(object.discipline_array.map { |discipline| discipline_image(discipline, options) }, ' ')
  end

  def slug_info
    h.render('slug_info')
  end

  def assessments_overview
    h.render 'assessments_overview', assessments: assessments
  end
end
