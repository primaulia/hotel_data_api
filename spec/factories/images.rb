FactoryBot.define do
  factory :image do
    image_type { 'rooms' }
    link { 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg' }
    description { 'Double room' }
    hotel
  end
end
