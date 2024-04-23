module Procurer
  class Service
    def initialize(name)
      @name = name
    end

    # delegate the call the subclass
    delegate :call, to: :instance_klass

    def instance_klass
      debugger
      klass = "Procurer::#{@name.capitalize}".constantize
      klass.new
    rescue NameError
      debugger
      # if somehow we haven't created the processor
      # we fall back the processor to the most generic processor
      Procurer::Fallback.new(@name)
    end

    private

    # the methods below can be used on-demand for any processor

    def store_string_attributes(hotel, hotel_data)
      whitelist = %i[name city country address description]
      whitelist.each do |attr|
        string_value = hotel_data[attr]

        if hotel.new_record?
          hotel.send("#{attr}=", string_value)
        else
          hotel.send("#{attr}=", string_value) if string_value.present? && string_value.length > hotel.try(attr).length
        end
      end

      hotel
    end

    def store_images(hotel, hotel_data)
      hotel_data[:images].each do |type, array|
        array.each do |image_hash|
          Image.find_or_create_by!(
            image_type: type.to_s,
            hotel_id: hotel.id,
            link: image_hash[:link],
            description: image_hash[:description]
          )
        end
      end

    end

    def store_amenities(hotel, hotel_data)
      hotel_data[:amenities].each do |type, array|
        array.each do |name|
          Amenity.find_or_create_by!(amenity_type: type.to_s, hotel_id: hotel.id, name:)
        end
      end
    end

    def store_booking_conditions(hotel, hotel_data)
      hotel_data[:booking_conditions].each do |condition|
        # create booking conditions
        BookingCondition.find_or_create_by!(hotel_id: hotel.id, condition:)
      end
    end

    # general parser
    def parse_data(hash)
      hash.map do |key, value|
        hash[key] = value.strip if value.is_a?(String) && key != :id # clean string values
      end

      hash = hash.transform_keys(&:underscore)

      hash
    end
  end
end
