class ApiClient
  def initialize
    @base_url = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers'
  end

  def call
    @raw_data = retrieve_data
    clean_data
  end

  private

  def api_url
    "#{@base_url}/#{@endpoint}"
  end

  def retrieve_data
    response = RestClient.get api_url, { accept: :json }
    JSON.parse(response.body)
  end
end
