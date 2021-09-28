# frozen_string_literal: true

require_dependency 'm3'

class M3::Login::VerificationsController < ApplicationController
  disable_tracking
  default_actions for_class: M3::Login::Base

  def verify
    M3::Login::Base.find_by!(verify_token: params[:token]).verify!
    flash[:info] = I18n.t('m3.login.verifications.verification_successful')
    redirect_to(Rails.application.config.m3.session.login_url)
  end
end
