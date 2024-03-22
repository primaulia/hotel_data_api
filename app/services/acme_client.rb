class AcmeClient
  BASE_URL = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme'

  def self.get_hotels
    response = RestClient.get BASE_URL, { accept: :json }
    JSON.parse(response.body)
  end
end
