require 'rails_helper'

RSpec.describe HotelProcurer do
  before(:each) do
    mock_response_path = Rails.root.join('spec/fixtures/api_response.json')
    mock_response_body = File.read(mock_response_path)

    stub_request(:get, 'https://pure-wildwood-78321-c62eac623fe7.herokuapp.com/')
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body: mock_response_body, headers: {})
  end

  describe '__retrieved_data' do
    it 'returns a list of cleaned hotels' do
      # Procure the data
      hotels = described_class.new.send(:retrieved_data)

      # Assert the response
      expect(hotels.size).to eq(3)
      hotels.each do |hotel|
        expect(hotel.keys).to match_array(%w[id destination_id address amenities booking_conditions city country
                                             description images lat lng name])
      end
    end
  end

  describe '__create_destinations' do
    let(:data) { described_class.new.send(:retrieved_data).first.symbolize_keys }
    let(:destination) { create(:destination) }
    it 'creates a destination based on the given destination_id' do
      id = data[:destination_id]
      expect { described_class.new.send(:create_destination, id) }.to change(Destination, :count).by(1)
      expect(Destination.first.id).to eq(id)
    end

    it 'doesnt create a new one if the destination already exists' do
      id = data[:destination_id]
      destination.update_columns(id:)
      expect { described_class.new.send(:create_destination, id) }.not_to change(Destination, :count)
    end
  end

  describe '__create_hotel' do
    let(:data) { described_class.new.send(:retrieved_data).first.symbolize_keys }
    let(:destination) { create(:destination) }
    let(:hotel) { create(:hotel, destination:) }
    it 'creates a hotel based on the given data' do
      described_class.new.send(:create_destination, data[:destination_id])
      expect { described_class.new.send(:create_hotel, data) }.to change(Hotel, :count).by(1)
      expect(Hotel.first.slug).to eq(data[:id])
    end

    it 'doesnt create a new one if the hotel already exists' do
      data[:destination_id] = destination.id
      hotel.update_columns(slug: data[:id])
      expect { described_class.new.send(:create_hotel, data) }.not_to change(Hotel, :count)
      expect(Hotel.first.destination_id).to eq(destination.id)
    end
  end

  describe '__setup_amenities' do
    let(:data) { described_class.new.send(:retrieved_data).first.symbolize_keys }
    let(:destination) { create(:destination) }
    let(:hotel) { create(:hotel, destination:) }
    let!(:amenity) { create(:amenity, hotel:) }

    it 'creates amenities record based for the given hotel' do
      expect do
        described_class.new.send(:setup_amenities, data[:amenities],
                                 hotel)
      end.to change(Amenity, :count).by(data[:amenities].values.map(&:count).sum - 1)
      expect(Amenity.first.hotel_id).to eq(hotel.id)
    end

    it 'doesn\'t recreate a new amenities record if it already exist' do
      given_amenities = {
        'general' => [
          'aircon',
          'business center'
        ]
      }
      expect do
        described_class.new.send(:setup_amenities, given_amenities,
                                 hotel.reload)
      end.to change(Amenity, :count).by(1)
      expect(Amenity.first.hotel_id).to eq(hotel.id)
      expect(hotel.reload.amenities.count).to eq(2)
      expect(hotel.amenities.pluck(:name)).to match_array(['aircon', 'business center'])
    end

    it 'cleans all the unused amenities' do
      given_amenities = {
        'general' => [
          'xxx'
        ]
      }

      described_class.new.send(:setup_amenities, given_amenities,
                               hotel.reload)
      expect(hotel.amenities.count).to eq(1)
    end
  end

  describe '__setup_images' do
    let(:data) { described_class.new.send(:retrieved_data).first.symbolize_keys }
    let(:destination) { create(:destination) }
    let(:hotel) { create(:hotel, destination:) }
    let!(:image) { create(:image, hotel:) }

    it 'creates images record based for the given hotel' do
      expect do
        described_class.new.send(:setup_images, data[:images],
                                 hotel)
      end.to change(Image, :count).by(data[:images].values.map(&:count).sum - 1)
      expect(Image.first.hotel_id).to eq(hotel.id)
    end

    it 'doesn\'t recreate image if it already exists' do
      given_images = {
        'rooms' => [
          {
            'link' => 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg',
            'description' => 'Double room'
          },
          {
            'link' => 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i94_m.jpg',
            'description' => 'Bathroom'
          }
        ]
      }

      expect do
        described_class.new.send(:setup_images, given_images,
                                 hotel)
      end.to change(Image, :count).by(1)
      expect(Image.first.hotel_id).to eq(hotel.id)
      expect(hotel.reload.images.count).to eq(2)
      expect(hotel.images.pluck(:link)).to match_array(['https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg', 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i94_m.jpg'])
    end

    it 'cleans all the unused images' do
      given_images = {
        'rooms' => [
          {
            'link' => 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/xxx_m.jpg',
            'description' => 'Single room'
          }
        ]
      }

      described_class.new.send(:setup_images, given_images,
                               hotel.reload)
      expect(hotel.images.count).to eq(1)
    end
  end

  describe '#call' do
    it 'creates the appropriate model according to the returned data' do
      # Procure the data and save it to the db
      expect { described_class.new.call }.to change {
                                               [Destination.count, Hotel.count, Amenity.count, Image.count]
                                             }.by([2, 3, 31, 12]) # based on the mock api response

      # if it's called again, nothing will change
      expect { described_class.new.call }.not_to change { [Destination.count, Hotel.count, Amenity.count, Image.count] }
    end
  end

  xit 'raises an error for unsuccessful requests' do
    # Mock the HTTP request to fail
    stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme')
      .with(headers: { 'Accept' => '*/*' })
      .to_return(status: 500, body: '', headers: {})

    # Expect an exception
    expect { AcmeClient.get_hotels }.to raise_error(StandardError)  # Replace with specific error type if applicable
  end
end
