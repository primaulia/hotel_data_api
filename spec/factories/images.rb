FactoryBot.define do
  factory :image do
    image_type { 'rooms' }
    sequence(:link) { |n| "https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i#{n}_m.jpg" }
    description { 'Double room' }
    hotel
  end
end
