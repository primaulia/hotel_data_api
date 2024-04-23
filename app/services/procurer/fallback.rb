module Procurer
  class Fallback < Procurer::Service
    def initialize(name)
      # assumed that the supplier will have the same base_url
      url = "https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/#{name}"
      @response = JSON.parse(RestClient.get(url))
    rescue RestClient::ExceptionWithResponse => err
      raise StandardError, "Invalid API endpoints provided"
    end

    def call
      @response.each do |hash|
        hotel_data = parse_data(hash)

        destination = Destination.find_or_create_by(id: hotel_data[:destination_id])

        hotel = Hotel.find_or_initialize_by(
          slug: hotel_data[:id],
          destination_id: destination.id
        )

        # assumed that the lat and lng will be the same
        hotel.lat = hotel_data[:lat] if hotel_data[:lat].present?
        hotel.lng = hotel_data[:lng] if hotel_data[:lat].present?

        hotel = store_string_attributes(hotel, hotel_data)

        hotel.save!
      end
    end

    private

    # the most basic parser
    # assumed that it has at least the basic string attributes
    def parse_data(hash)
      hash = super(hash)
      hash = hash.deep_symbolize_keys
      hash
    end
  end
end
