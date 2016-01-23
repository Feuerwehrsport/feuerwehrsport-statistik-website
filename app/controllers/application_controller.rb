class ApplicationController < ActionController::Base
  include Caching::CacheSupport

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
end
