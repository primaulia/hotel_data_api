module Procurer
  class Paperflies < Procurer::Service
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
        store_amenities(hotel, hotel_data)
        store_booking_conditions(hotel, hotel_data)

        hotel.save!
      end
    end

    private

    def parse_data(hash)
      hash = super(hash)
      hash = hash.transform_keys('hotel_id' => :id, 'hotel_name' => :name, 'details' => :description)
             .deep_symbolize_keys

      hash[:address] = hash[:location][:address]
      hash[:country] = hash[:location][:country]
      hash.delete(:location) # remove location value (destructured)

      # sync images value
      new_images = hash[:images].deep_transform_keys do |key|
        key == :caption ? :description : key
      end

      hash[:images] = new_images
      hash
    end
  end
end
