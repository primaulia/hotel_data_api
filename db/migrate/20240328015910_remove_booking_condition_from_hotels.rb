class RemoveBookingConditionFromHotels < ActiveRecord::Migration[7.0]
  def change
    remove_column :hotels, :booking_conditions
  end
end
