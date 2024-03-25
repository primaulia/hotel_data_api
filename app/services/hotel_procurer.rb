class HotelProcurer
  def initialize
    @base_url = 'https://pure-wildwood-78321-c62eac623fe7.herokuapp.com/'
  end

  def call
    data = retrieve_data
    errors = []

    data.each do |raw_hotel|
      hotel = raw_hotel.symbolize_keys
      begin
        create_destinations(hotel)
        create_hotels(hotel)
      rescue StandardError => e
        errors << { hotel:, error: e.message }  # Log error details
      end
    end
  end

  private

  def retrieve_data
    response = RestClient.get @base_url, { accept: :json }
    JSON.parse(response.body)
  end

  def create_destination(hotel)
    destination_id = hotel[:destination_id]
    Destination.find_or_create_by(id: destination_id)
  end

  def create_hotels(hotel); end
end
