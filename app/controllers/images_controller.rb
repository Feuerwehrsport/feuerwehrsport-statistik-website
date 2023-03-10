# frozen_string_literal: true

class ImagesController < ApplicationController
  def la_positions
    person = Person.find(params[:person_id])
    image = People::LaPositionsImage.new(person:).create_image
    send_data image.to_blob,
              disposition: 'inline',
              type: 'image/png'
  end
end
