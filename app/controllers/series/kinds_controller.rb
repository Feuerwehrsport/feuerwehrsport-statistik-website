# frozen_string_literal: true

class Series::KindsController < ResourceController
  resource_actions :index, cache: %i[index]

  def index
    @page_title = 'Wettkampfserien'
  end
end
