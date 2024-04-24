class Amenity < ApplicationRecord
  belongs_to :hotel

  validates :name, :amenity_type, presence: true
end
