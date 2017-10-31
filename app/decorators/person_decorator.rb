class PersonDecorator < AppDecorator
  decorates_association :nation
  decorates_association :bla_badge
  localizes_gender

  delegate :to_s, to: :full_name

  def page_title
    "#{full_name} - Wettkämpfer"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{first_name[0]}. #{last_name}"
  end

  def searchable_name
    "#{last_name}, #{first_name}"
  end
end
