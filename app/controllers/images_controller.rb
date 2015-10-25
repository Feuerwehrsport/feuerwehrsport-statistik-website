class ImagesController < ApplicationController
  def la_positions
    person = Person.find(params[:person_id])
    canvas = Image::Positions.new(person).create_image
    canvas.format = "png"
    send_data canvas.to_blob,
      
      disposition: 'inline',
      quality: 90,
      type: 'image/png'
  end
end