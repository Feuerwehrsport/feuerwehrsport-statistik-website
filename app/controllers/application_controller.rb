class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  helper_method def page_title
    @page_title || page_title_default
  end

  protected

  def current_user
    current_admin_user || AdminUser.guest
  end
  
  def page_title_default(default=nil)
    action = params['action']
    controller_segment = controller_path.gsub('/', '.')
    I18n.translate("#{controller_segment}.#{action}.page_title", default: translate("#{controller_segment}.page_title", default: default))
  end
end
