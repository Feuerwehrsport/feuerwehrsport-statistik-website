class ApplicationController < ActionController::Base
  include Caching::CacheSupport
  include PDFSupport
  
  # handle access denied
  rescue_from CanCan::AccessDenied do |exception|
    if admin_user_signed_in?
      flash[:danger] = "Sie verfügen nicht über die Rechte, die angeforderte Seite anzuzeigen."
      redirect_to backend_root_path
    else
      flash[:danger] = "Bitte melden Sie sich an, um die angeforderte Seite anzuzeigen."
      session[:requested_url_before_login] = request.fullpath
      redirect_to new_admin_user_session_path
    end
  end

  helper_method def page_title
    @page_title || page_title_default
  end

  protected
  
  def page_title_default(default=nil)
    action = params['action']
    controller_segment = controller_path.gsub('/', '.')
    I18n.translate("#{controller_segment}.#{action}.page_title", default: translate("#{controller_segment}.page_title", default: default))
  end

  def authorize!(action_name, model, *args)
    model = model.object if model.is_a?(Draper::Decorator)
    super(action_name, model, *args)
  end

  def can?(action_name, model, *args)
    model = model.object if model.is_a?(Draper::Decorator)
    super(action_name, model, *args)
  end

  def deliver(mailer, method, *args)
    args = args.map do |arg|
      arg = arg.object if arg.is_a?(Draper::Decorator)
      arg
    end
    mailer.send(method, *args).deliver_later
  end

  def self.current_controller_namespace
    ""
  end

  def after_sign_in_path_for(resource)
    if session[:requested_url_before_login].present?
      session.delete(:requested_url_before_login)
    else
      backend_root_path
    end
  end
  
  def after_sign_out_path_for(resource_or_scope)
    new_admin_user_session_path
  end
end
