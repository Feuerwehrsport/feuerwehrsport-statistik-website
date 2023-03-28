# frozen_string_literal: true

class Registrations::BandsController < Registrations::BaseController
  default_actions :new, :create, :index, :edit, :update, :destroy
  belongs_to Registrations::Competition, url: -> { url_for(parent_resource) }

  default_form do |f|
    f.input :name
    f.input :gender, as: :radio_buttons

    f.inputs 'Markierungen' do
      f.input :person_tags
      f.input :team_tags
    end
  end

  def edit
    if params[:move] == 'up'
      form_resource.move_higher
      redirect_to action: :index
    elsif params[:move] == 'down'
      form_resource.move_lower
      redirect_to action: :index
    end
  end

  def new_assessment
    assign_resource
  end

  def paginate?
    false
  end
end
