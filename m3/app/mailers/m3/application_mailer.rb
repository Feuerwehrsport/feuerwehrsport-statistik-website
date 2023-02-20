# frozen_string_literal: true

class M3::ApplicationMailer < ActionMailer::Base
  layout 'm3_mailer'
  attr_accessor :website, :locale

  class_attribute :delayed_queue
  alias m3_website website
  helper_method :website, :m3_website, :locale
  delegate :delivery_setting, to: :website

  def self.configure(website, locale, method_name, *args)
    mailer = new
    mailer.website = website
    mailer.locale = locale
    mailer.process(method_name, *args)
    mailer.message
  end

  protected

  def mail(options, &block)
    I18n.with_locale(body_locale) do
      options = default_options(options).merge(options)
      set_default_url_options(options)
      message = super(options, &block)
      message.delivery_method(delivery_setting.delivery_method, delivery_setting.to_settings_hash)
      message
    end
  end

  def body_locale
    locale || I18n.default_locale
  end

  def params_locale
    locale
  end

  def email_address_format(email_address, name = '')
    address = Mail::Address.new(email_address)
    display_name = name.to_s.dup.presence&.delete("\r\n")&.strip
    address.display_name = display_name if display_name
    address.format
  end

  def default_options(options)
    default_options = {}
    %i[from reply_to].each do |a|
      next unless delivery_setting.send(:"#{a}_address").present? || options[:"#{a}_address"].present?

      email_address = options.delete(:"#{a}_address") || delivery_setting.send(:"#{a}_address")
      email_name = options.delete(:"#{a}_name") || delivery_setting.send(:"#{a}_name")
      default_options[a] = email_address_format(email_address, email_name)
    end
    default_options
  end

  def website_default_url_options(options = {})
    {
      host: options.delete(:host) || website.domain,
      port: options.delete(:port) || website.port,
      protocol: options.delete(:protocol) || website.protocol,
      locale: params_locale,
    }
  end

  def set_default_url_options(options = {})
    new_options = website_default_url_options(options)
    self.default_url_options = new_options
    uri_class = new_options[:protocol].to_sym == :https ? URI::HTTPS : URI::HTTP
    self.asset_host = uri_class.build(new_options).to_s
  end

  def t(key, interpolations = {})
    interpolations[:locale] = locale if interpolations[:locale].blank?
    super(key, interpolations)
  end
end
