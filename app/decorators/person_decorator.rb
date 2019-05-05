class PersonDecorator < AppDecorator
  decorates_association :nation
  decorates_association :bla_badge
  localizes_gender

  delegate :to_s, to: :full_name
  delegate :nation_flag_with_iso, to: :nation

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

  def link_to(method)
    h.link_to(public_send(method), self)
  end

  %i[hb_count hl_count gs_count fs_count la_count].each do |method|
    define_method method do
      h.count_or_zero(object.public_send(method))
    end
  end
end
