class CreateHotels < ActiveRecord::Migration[7.0]
  def change
    create_table :hotels do |t|
      t.string :slug, unique: true
      t.string :name
      t.string :address
      t.float :lat
      t.float :lng
      t.string :city
      t.string :country
      t.string :description
      t.string :booking_conditions, array: true
      t.references :destination, null: false, foreign_key: true

      t.timestamps
    end

    add_index :hotels, :slug, unique: true
  end
end
