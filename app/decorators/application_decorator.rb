class ApplicationDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def self.collection_decorator_class
    ApplicationCollectionDecorator
  end

  def translated_gender
    t("gender.#{object.gender}")
  end

  def gender_symbol
    t("gender.#{gender}_symbol")
  end

  def self.calculate_second_time(time)
    return "D" if time == TimeInvalid::INVALID
    sprintf("%.2f", (time.to_f/100)).sub(".", ",")
  end

  protected

  def calculate_second_time(time)
    self.class.calculate_second_time(time)
  end

end
