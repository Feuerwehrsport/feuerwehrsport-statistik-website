# frozen_string_literal: true

# read only, used by Feusport (ImportSuggestionsJob, with extended=1)
class Api::PeopleController < Api::BaseController
  api_actions :index

  protected

  def base_collection
    if params[:gender].present?
      super.reorder(:last_name, :first_name).gender(params[:gender])
    else
      super.reorder(:last_name, :first_name)
    end
  end

  def serializer_for_object(object)
    object.is_a?(Person) && params[:extended].present? ? ExtendedPersonSerializer.new(object.decorate) : super
  end
end
