# frozen_string_literal: true

class Registrations::AssessmentsController < Registrations::BaseController
  default_actions :new, :create, :index, :edit, :update, :destroy
  belongs_to Registrations::Competition, url: -> { url_for(parent_resource) }

  default_form do |f|
    f.input :discipline, as: :radio_buttons
    f.input :gender, as: :radio_buttons
    f.input :name
    f.input :show_only_name
  end

  def paginate?
    false
  end
end
