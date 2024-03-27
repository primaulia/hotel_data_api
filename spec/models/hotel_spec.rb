require 'rails_helper'

RSpec.describe Hotel, type: :model do
  describe 'validations' do
    subject(:hotel) { build(:hotel) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_presence_of(:address) }
    it { should belong_to(:destination) }
    it { should have_many(:amenities) }
    it { should have_many(:images) }
  end
end
