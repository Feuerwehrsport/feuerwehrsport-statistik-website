class ApplicationController < M3::ApplicationController
  include Caching::CacheSupport
  include PDFSupport
  include PageTitleHelper
  include MapSupport
  helper_method :current_admin_user, :current_user

  protected

  def send_pdf(klass, *args)
    pdf = klass.build(*args)
    send_data(pdf.bytestream, filename: pdf.filename, type: 'application/pdf', disposition: 'inline')
  end

  def current_admin_user
    @current_admin_user ||= AdminUser.for_login(current_login)
  end

  def current_user
    current_admin_user
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user, current_login)
  end

  def select_layout
    'application'
  end
end
