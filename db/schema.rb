# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_28_015425) do
  create_table "amenities", force: :cascade do |t|
    t.integer "hotel_id", null: false
    t.string "name"
    t.string "amenity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hotel_id"], name: "index_amenities_on_hotel_id"
  end

  create_table "booking_conditions", force: :cascade do |t|
    t.string "condition"
    t.integer "hotel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hotel_id"], name: "index_booking_conditions_on_hotel_id"
  end

  create_table "destinations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hotels", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.string "address"
    t.float "lat"
    t.float "lng"
    t.string "city"
    t.string "country"
    t.string "description"
    t.string "booking_conditions"
    t.integer "destination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_hotels_on_destination_id"
    t.index ["slug"], name: "index_hotels_on_slug", unique: true
  end

  create_table "images", force: :cascade do |t|
    t.string "image_type"
    t.string "link"
    t.string "description"
    t.integer "hotel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hotel_id"], name: "index_images_on_hotel_id"
  end

  add_foreign_key "amenities", "hotels"
  add_foreign_key "booking_conditions", "hotels"
  add_foreign_key "hotels", "destinations"
  add_foreign_key "images", "hotels"
end
