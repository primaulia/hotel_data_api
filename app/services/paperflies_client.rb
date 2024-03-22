class PaperfliesClient
  BASE_URL = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/paperflies'.freeze

  def self.call
    response = RestClient.get BASE_URL, { accept: :json }
    JSON.parse(response.body)
  end
end
