module Procurer
  class Patagonia < Procurer::Service
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
        store_images(hotel, hotel_data)

        hotel.save!
      end
    end

    private

    def parse_data(hash)
      hash = super(hash)
      hash = hash.transform_keys('destination' => :destination_id, 'info' => :description)
             .deep_symbolize_keys

      hash.delete(:amenities) # remove amenities value (unstructured data)

      # sync images value
      new_images = hash[:images].deep_transform_keys do |key|
        key == :url ? :link : key
      end

      hash[:images] = new_images
      hash
    end
  end
end
