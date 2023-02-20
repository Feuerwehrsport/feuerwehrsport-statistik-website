# frozen_string_literal: true

class Api::TeamsController < Api::BaseController
  api_actions :create, :show, :index, :update,
              change_log: true,
              create_form: %i[name shortcut status]
  include MergeAction

  form_for :update do |f|
    f.input :latitude
    f.input :longitude
    f.input :state

    if can?(:correct, resource)
      f.input :name
      f.input :shortcut
      f.input :status
      f.input :image_change_request
    end
  end

  protected

  def base_collection
    super.reorder(:name)
  end

  def resource_show_object
    params[:extended].present? ? ExtendedTeamSerializer.new(resource.decorate) : super
  end
end
