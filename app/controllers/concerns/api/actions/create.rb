module API::Actions::Create
  extend ActiveSupport::Concern

  protected

  def after_create
    success(created_id: form_resource.id)
  end

  def after_create_failed
    failed
  end
end
