FactoryBot.define do
  factory :amenity do
    hotel
    name { 'aircon' }
    amenity_type { 'room' }
  end
end
