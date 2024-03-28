class CreateBookingConditions < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_conditions do |t|
      t.string :condition
      t.references :hotel, null: false, foreign_key: true

      t.timestamps
    end
  end
end
