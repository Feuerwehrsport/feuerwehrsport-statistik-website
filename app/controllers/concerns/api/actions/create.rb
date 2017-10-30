module API::Actions::Create
  extend ActiveSupport::Concern

  protected

  def after_create
    success
  end

  def after_create_failed
    failed
  end
end
