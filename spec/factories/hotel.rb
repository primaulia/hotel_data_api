FactoryBot.define do
  factory :hotel do
    destination
    slug { 'xxx' }
    name { 'Hotel XXX' }
    address { '1 xxx road' }
    city { 'Singapore' }
    description { 'This is an xxx hotel' }
    booking_conditions { [] }
    country { 'Singapore' }
    lat { 0.0 }
    lng { 0.0 }
  end
end
