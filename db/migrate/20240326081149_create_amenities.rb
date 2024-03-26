class CreateAmenities < ActiveRecord::Migration[7.0]
  def change
    create_table :amenities do |t|
      t.references :hotel, null: false, foreign_key: true
      t.string :name
      t.string :amenity_type

      t.timestamps
    end
  end
end
