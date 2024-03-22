require 'rails_helper'

RSpec.describe PatagoniaClient do
  describe '::call' do
    it 'returns a list of hotels when successful' do
      mock_response_path = Rails.root.join('spec/fixtures/patagonia_api_response.json')
      mock_response_body = File.read(mock_response_path)

      stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/patagonia')
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body: mock_response_body, headers: {})

      # Call the service method
      hotels = described_class.call

      # Assert the response
      expect(hotels).to all(have_key('name'))
    end
  end
end
