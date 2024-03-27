require 'rails_helper'

RSpec.describe Amenity, type: :model do
  describe 'validations' do
    subject(:amenity) { build(:amenity) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:amenity_type) }
    it { should validate_uniqueness_of(:name).scoped_to(:hotel_id) }
    it { should belong_to(:hotel) }
  end
end
