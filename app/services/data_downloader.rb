class DataDownloader
  attr_reader :data

  def initialize
    @data = HotelProcurer.new.call
  end

  def call
    raise StandardError, 'Data procurement has failed' if @data.nil?

    @data.each do |hotel_data|
      setup_models(hotel_data)
    end
  end

  private

  def setup_models(hotel_data)
    destination_id = hotel_data[:destination_id]
    create_destination(destination_id)
    hotel = create_hotel(hotel_data)
    setup_amenities(hotel_data[:amenities], hotel)
    setup_images(hotel_data[:images], hotel)
    setup_booking_conditions(hotel_data[:booking_conditions], hotel)
  end

  def create_destination(id)
    raise StandardError if id.nil?

    Destination.find_or_create_by!(id:)
  end

  def create_hotel(data)
    hotel = Hotel.find_or_initialize_by(slug: data[:id])
    hotel.update!(data.slice(:destination_id, :name, :address, :city, :country, :lat, :lng, :description))
    hotel
  end

  def setup_amenities(given_amenities, hotel)
    # create new amenities
    given_amenities.each do |type, array|
      array.each do |name|
        Amenity.find_or_create_by!(amenity_type: type.to_s, hotel_id: hotel.id, name:)
      end
    end

    # remove amenities that's not on the data
    hotel.amenities.each do |amenity|
      amenity.destroy! unless given_amenities[amenity.amenity_type.to_sym]&.include?(amenity.name)
    end
  end

  def setup_images(given_images, hotel)
    given_images.each do |type, array|
      array.each do |image_hash|
        Image.find_or_create_by!(image_type: type.to_s, hotel_id:
         hotel.id, link: image_hash[:link],
                                 description: image_hash[:description])
      end
    end

    # remove images that's not on the data
    hotel.images.each do |image|
      image_exist = given_images[image.image_type.to_sym]&.any? do |data|
        data[:link] == image.link && data[:description] && image.description
      end
      image.destroy! unless image_exist
    end
  end

  def setup_booking_conditions(given_conditions, hotel)
    given_conditions.each do |condition|
      # create booking conditions
      BookingCondition.find_or_create_by!(hotel_id: hotel.id, condition:)

      # remove unused conditions
      hotel.booking_conditions.each do |cond|
        cond.destroy! unless given_conditions.include?(cond.condition)
      end
    end
  end
end
