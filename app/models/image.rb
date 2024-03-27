class Image < ApplicationRecord
  belongs_to :hotel

  validates :link, :description, presence: true
  validates :link, uniqueness: { scope: :hotel_id }
end
