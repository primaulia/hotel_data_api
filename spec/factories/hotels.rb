FactoryBot.define do
  factory :hotel do
    destination
    sequence(:slug) { |n| "xxx#{n}" }
    sequence(:name) { |n| "Hotel XXX#{n}" }
    sequence(:address) { |n| "#{n} xxx road" }
    city { 'Singapore' }
    description { 'This is an xxx hotel' }
    booking_conditions { [] }
    country { 'Singapore' }
    lat { 0.0 }
    lng { 0.0 }
  end
end
