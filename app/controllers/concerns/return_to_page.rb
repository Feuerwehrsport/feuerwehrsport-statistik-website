# frozen_string_literal: true

# app/(models|controllers)/concerns/
module ReturnToPage
  extend ActiveSupport::Concern

  included do
    helper_method :return_page_or_url
  end

  def return_page_or_url(url)
    return url_for(params[:rtp]) if params[:rtp]

    url_for(url)
  end

  def default_url_options
    super.merge(rtp: params[:rtp])
  end
end
