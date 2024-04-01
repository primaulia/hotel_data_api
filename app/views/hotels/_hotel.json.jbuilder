json.cache! ['hotel', hotel], expires_in: 10.minutes do
  json.id hotel.slug
  json.extract! hotel, :destination_id, :name, :description
  json.location do
    json.extract! hotel, :lat, :lng, :address, :city, :country
  end
  json.amenities hotel.amenities_list
  json.images hotel.images_list
  json.booking_conditions hotel.booking_conditions.pluck(:condition)
end
