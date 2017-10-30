class EventDecorator < AppDecorator
  decorates_association :competitions

  delegate :to_s, to: :name

  def page_title
    "#{name} - Wettkampftyp"
  end
end
