require 'rails_helper'

RSpec.describe HotelProcurer do
  describe '#call' do
    it 'returns a list of cleaned hotels' do
      mock_response_path = Rails.root.join('spec/fixtures/api_response.json')
      mock_response_body = File.read(mock_response_path)

      stub_request(:get, 'https://pure-wildwood-78321-c62eac623fe7.herokuapp.com/')
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body: mock_response_body, headers: {})

      # Call the service method
      hotels = described_class.new.call

      # Assert the response
      expect(hotels.size).to eq(3)
      hotels.each do |hotel|
        expect(hotel.keys).to match_array(%w[id destination_id address amenities booking_conditions city country
                                             description images lat lng name])
      end
    end

    it

    xit 'raises an error for unsuccessful requests' do
      # Mock the HTTP request to fail
      stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme')
        .with(headers: { 'Accept' => '*/*' })
        .to_return(status: 500, body: '', headers: {})

      # Expect an exception
      expect { AcmeClient.get_hotels }.to raise_error(StandardError)  # Replace with specific error type if applicable
    end
  end
end
