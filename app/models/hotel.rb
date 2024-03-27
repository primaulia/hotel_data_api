class Hotel < ApplicationRecord
  belongs_to :destination
  has_many :amenities, dependent: :destroy
  has_many :images, dependent: :destroy

  validates :name, :slug, :address, presence: true
  validates :slug, uniqueness: true

  def amenities_list
    hash = {}
    available_amenity_types.each do |type|
      hash[type] = amenities.where(amenity_type: type).pluck(:name)
    end
    hash
  end

  def images_list
    hash = {}
    available_image_types.each do |type|
      hash[type] = []
      images.where(image_type: type).map do |image|
        hash[type] << { link: image.link, description: image.description }
      end
    end
    hash
  end

  private

  def available_amenity_types
    amenities.select(:amenity_type).distinct.pluck(:amenity_type)
  end

  def available_image_types
    images.select(:image_type).distinct.pluck(:image_type)
  end
end
