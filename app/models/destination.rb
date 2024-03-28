class Destination < ApplicationRecord
  has_many :hotels, dependent: :destroy
end
