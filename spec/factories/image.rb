FactoryBot.define do
  factory :image do
    image_type { 'rooms' }
    link { 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg' }
    description { 'Double room' }
    hotel
  end
end
