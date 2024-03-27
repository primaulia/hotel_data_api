class Hotel < ApplicationRecord
  belongs_to :destination
  has_many :amenities, dependent: :destroy
  has_many :images, dependent: :destroy

  validates :name, :slug, :address, presence: true
  validates :slug, uniqueness: true
end
