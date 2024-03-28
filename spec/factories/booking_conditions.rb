FactoryBot.define do
  factory :booking_condition do
    condition { 'WiFi is available in all areas and is free of charge.' }
    hotel
  end
end
