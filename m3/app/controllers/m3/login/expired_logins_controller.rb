# frozen_string_literal: true

class M3::Login::ExpiredLoginsController < M3::Login::PasswordResetsController
  protected

  def build_resource
    resource_class.new(website: m3_website, email_address: params[:email_address])
  end
end
