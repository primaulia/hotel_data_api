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
    it { should have_many(:booking_conditions) }
  end

  describe '#amenities_list' do
    let(:hotel) { create(:hotel) }
    let!(:aircon) { create(:amenity, hotel:, name: 'aircon', amenity_type: 'room') }
    let!(:pool) { create(:amenity, hotel:, name: 'outdoor pool', amenity_type: 'general') }
    let!(:playground) { create(:amenity, hotel:, name: 'playground', amenity_type: 'general') }

    it 'should return a hash of amenity list grouped by type' do
      expect(hotel.amenities_list.keys).to match_array(%w[room general])
      expect(hotel.amenities_list['general'].size).to eq(2)
      expect(hotel.amenities_list['general']).to include('outdoor pool')
      expect(hotel.amenities_list['room'].size).to eq(1)
      expect(hotel.amenities_list['room']).to include('aircon')
    end
  end

  describe '#images_list' do
    let(:hotel) { create(:hotel) }
    let!(:room1) { create(:image, hotel:, description: 'Double room', image_type: 'rooms') }
    let!(:room2) { create(:image, hotel:, description: 'Single room', image_type: 'rooms') }
    let!(:site) { create(:image, hotel:, description: 'Front', image_type: 'site') }

    it 'should return a hash of images list grouped by type' do
      expect(hotel.images_list.keys).to match_array(%w[rooms site])
      expect(hotel.images_list['rooms'].size).to eq(2)
      expect(hotel.images_list['rooms'].pluck(:description)).to include('Double room')
      expect(hotel.images_list['site'].size).to eq(1)
      expect(hotel.images_list['site'].pluck(:description)).to include('Front')
    end
  end
end
