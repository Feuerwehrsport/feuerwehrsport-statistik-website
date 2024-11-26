# frozen_string_literal: true

class RemoveAppointments < ActiveRecord::Migration[7.0]
  def change
    drop_table :appointments
  end
end
