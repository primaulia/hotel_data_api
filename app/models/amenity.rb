class Amenity < ApplicationRecord
  belongs_to :hotel

  validates :name, :amenity_type, presence: true
  validates :name, uniqueness: { scope: :hotel_id }
end
