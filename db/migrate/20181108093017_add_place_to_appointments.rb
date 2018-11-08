class AddPlaceToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :place, :string, limit: 200
    Appointment.where.not(place_id: nil).each do |appointment|
      place = Place.find(appointment[:place_id])
      appointment.update!(place: place.name)
    end
    remove_column :appointments, :place_id
  end
end
