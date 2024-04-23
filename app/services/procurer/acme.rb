module Procurer
  class Acmes < Procurer::Service
    def initialize
      url = "https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme"
      @response = JSON.parse(RestClient.get(url))
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

    # parser specific to acme
    def parse_data(hash)
      hash = super(hash)
      hash = hash.transform_keys('latitude' => :lat, 'longitude' => :lng)
             .deep_symbolize_keys

      hash.delete(:facilities) # remove facilities value (unstructured data)
      hash.delete(:postal_code)
      hash
    end
  end
end
