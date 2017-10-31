class Backend::BLA::BadgeGeneratorsController < Backend::BackendController
  backend_actions :new, :create

  default_form do |f|
    f.input :year, as: :select, collection: Year.all.map(&:to_i)
  end

  protected

  def after_create
    render :create
  end
end
