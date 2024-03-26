class Hotel < ApplicationRecord
  belongs_to :destination
  has_many :amenities, dependent: :destroy
  has_many :images, dependent: :destroy
end
