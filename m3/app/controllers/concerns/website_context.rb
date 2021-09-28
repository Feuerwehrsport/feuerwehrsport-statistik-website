# frozen_string_literal: true

module WebsiteContext
  extend ActiveSupport::Concern

  included do
    prepend_before_action :assign_m3_website
    attr_accessor :m3_website
  end

  def assign_m3_website
    @m3_website = M3::Website.find_by(domain: request.host)
    return if @m3_website.present?

    if respond_to?(:m3_website_blank_handler)
      m3_website_blank_handler
    else
      default_site = M3::Website.find_by!(default_site: true)
      redirect_to url_for(
        host: default_site.domain,
        port: default_site.port,
        protocol: default_site.protocol,
      )
    end
  end

  def select_layout
    @m3_website.layout
  end
end
