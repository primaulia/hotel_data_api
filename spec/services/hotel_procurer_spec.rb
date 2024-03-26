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
    it 'creates a destination based on the given destination_id' do
      id = data[:destination_id]
      expect { described_class.new.send(:create_destination, id) }.to change(Destination, :count).by(1)
      expect(Destination.first.id).to eq(id)
    end

    # TODO
    xit 'doesnt create a new one if the destination already exists' do
    end
  end

  describe '__create_hotel' do
    let(:data) { described_class.new.send(:retrieved_data).first.symbolize_keys }
    it 'creates a hotel based on the given data' do
      described_class.new.send(:create_destination, data[:destination_id])
      expect { described_class.new.send(:create_hotel, data) }.to change(Hotel, :count).by(1)
      expect(Hotel.first.slug).to eq(data[:id])
    end
  end

  describe '#call' do
    it 'creates the appropriate model according to the returned data' do
      # Procure the data and save it to the db
      expect { described_class.new.call }.to change { [Destination.count, Hotel.count] }.by([2, 3])

      # if it's called again, nothing will change
      expect { described_class.new.call }.not_to change { [Destination.count, Hotel.count] }
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
