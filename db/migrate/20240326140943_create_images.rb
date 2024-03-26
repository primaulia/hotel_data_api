class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :image_type
      t.string :link
      t.string :description
      t.references :hotel, null: false, foreign_key: true

      t.timestamps
    end
  end
end
