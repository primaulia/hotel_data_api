class BookingCondition < ApplicationRecord
  belongs_to :hotel

  validates :condition, presence: true
end
