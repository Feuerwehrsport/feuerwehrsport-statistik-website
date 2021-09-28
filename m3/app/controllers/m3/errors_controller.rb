# frozen_string_literal: true

class M3::ErrorsController < ApplicationController
  def not_found
    render(status: status_or_ok_on_generation(:not_found), formats: :html)
  end

  def unacceptable
    render(status: status_or_ok_on_generation(:unprocessable_entity), formats: :html)
  end

  def internal_server_error
    render(status: status_or_ok_on_generation(:internal_server_error), formats: :html)
  end

  protected

  def status_or_ok_on_generation(key)
    params[:generation].present? ? :ok : key
  end
end
