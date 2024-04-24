module Procurer
  class Acme < Procurer::Service
    def initialize(url)
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

        store_amenities(hotel, hotel_data)
      end
    end

    private

    # parser specific to acme
    def parse_data(hash)
      hash = super(hash)
      hash = hash.transform_keys('latitude' => :lat, 'longitude' => :lng)
             .deep_symbolize_keys


      # sync amenities value
      hash[:amenities] = hash.dig(:facilities) ? {
        general: hash[:facilities].map do |amenity|
          stripped_amenity = amenity.strip
          if stripped_amenity == "WiFi"
            stripped_amenity.downcase
          else
            stripped_amenity.underscore.humanize(capitalize: false)
          end
        end
      } : []

      hash.delete(:facilities) # remove facilities value (unstructured data)
      hash.delete(:postal_code)
      hash
    end
  end
end
