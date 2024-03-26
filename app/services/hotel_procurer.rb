class HotelProcurer
  def initialize
    @base_url = 'https://pure-wildwood-78321-c62eac623fe7.herokuapp.com/'
  end

  def call
    errors = []

    retrieved_data.each do |raw_hotel|
      hotel_data = raw_hotel.symbolize_keys
      begin
        setup_models(hotel_data)
      rescue StandardError => e
        errors << { hotel_data:, error: e.message }  # Log error details
      end
    end
  end

  private

  def retrieved_data
    response = RestClient.get @base_url, { accept: :json }
    JSON.parse(response.body)
  end

  def setup_models(hotel_data)
    destination_id = hotel_data[:destination_id]
    create_destination(destination_id)
    hotel = create_hotel(hotel_data)
    setup_amenities(hotel_data[:amenities], hotel)
  end

  def create_destination(id)
    Destination.find_or_create_by(id:)
  end

  def create_hotel(data)
    hotel = Hotel.find_or_initialize_by(slug: data[:id])
    hotel.update!(data.slice(:destination_id, :name, :address, :city, :country, :lat, :lng, :description,
                             :booking_conditions))
    hotel
  end

  def setup_amenities(given_amenities, hotel)
    # create new amenities
    given_amenities.each do |type, array|
      array.each do |name|
        Amenity.find_or_create_by(amenity_type: type, hotel_id: hotel.id, name:)
      end
    end

    # remove amenities that's not on the data
    hotel.amenities.each do |amenity|
      remove_amenity(amenity) unless given_amenities[amenity.amenity_type]&.include?(amenity.name)
    end
  end

  def remove_amenity(amenity)
    Amenity.find(amenity.id).destroy
  end
end
