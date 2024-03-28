FactoryBot.define do
  factory :booking_condition do
    condition { 'All children are welcome.' }
    hotel
  end
end
