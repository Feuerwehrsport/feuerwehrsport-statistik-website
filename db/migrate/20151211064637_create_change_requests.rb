class CreateChangeRequests < ActiveRecord::Migration
  def change
    create_table :change_requests do |t|
      t.references :user, index: true, foreign_key: true
      t.references :admin_user, index: true, foreign_key: true
      t.json :content, null: false
      t.datetime :done_at

      t.timestamps null: false
    end
  end
end
