FactoryBot.define do
  factory :amenity do
    hotel
    name { 'fan' }
    amenity_type { 'room' }
  end
end
