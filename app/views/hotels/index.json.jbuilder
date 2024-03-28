json.array! @hotels do |hotel|
  json.id hotel.slug
  json.destination_id hotel.destination_id
  json.name hotel.name
  json.location do
    json.lat hotel.lat
    json.lng hotel.lng
    json.address hotel.address
    json.city hotel.city
    json.country hotel.country
  end
  json.amenities hotel.amenities_list
  json.images hotel.images_list
  json.description hotel.description
  json.booking_conditions hotel.booking_conditions.pluck(:condition)
end
