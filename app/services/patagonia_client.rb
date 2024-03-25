class PatagoniaClient < ApiClient
  def initialize
    super
    @endpoint = 'patagonia'
  end

  private

  def clean_data
    @raw_data.map do |hotel|
      {
        id: hotel['id'],
        destination_id: hotel['destination'],
        name: hotel['name'],
        lat: hotel['lat'],
        lng: hotel['lng'],
        address: hotel['address'],
        description: hotel['info'],
        booking_conditions: hotel['booking_conditions']
      }
    end
  end
end
