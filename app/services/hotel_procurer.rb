class HotelProcurer
  def initialize
    @base_url = 'https://pure-wildwood-78321-c62eac623fe7.herokuapp.com/'
  end

  def call
    retrieve_data
  end

  private

  def retrieve_data
    response = RestClient.get @base_url, { accept: :json }
    JSON.parse(response.body)
  end
end
