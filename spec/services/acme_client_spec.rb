require 'rails_helper'

RSpec.describe AcmeClient do
  describe '#get_hotels' do
    it 'returns a list of hotels when successful' do
      mock_response_path = Rails.root.join('spec/fixtures/acme_api_response.json')
      mock_response_body = File.read(mock_response_path)
      mock_response = JSON.parse(mock_response_body)

      stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme')
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body: mock_response_body, headers: {})

      # Call the service method
      hotels = AcmeClient.get_hotels

      # Assert the response
      expect(hotels).to all(have_key('Name'))
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
end
