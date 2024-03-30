require 'geocoder'

class HotelProcurer
  def initialize
    @base_url = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/'
    @endpoints = %w[
      acme
      patagonia
      paperflies
    ]
    @data = []
  end

  def call
    @endpoints.each do |endpoint|
      call_api(endpoint)
    end

    merge_data
    complete_data
  end

  private

  def geocode_name(location)
    Geocoder.search(location)
  end

  def complete_data
    @data.map do |key, value|
      # geocode the name name + country if there's no coordinate value
      lat, lng = if value[:lat].nil?
                   geocode_name("#{value[:name]} #{value[:country]}").first.coordinates
                 else
                   [value[:lat],
                    value[:lng]]
                 end

      {
        id: key,
        destination_id: value[:destination_id],
        name: value[:name],
        lat:,
        lng:,
        address: value[:address],
        city: value[:city],
        country: value[:country],
        postal_code: value[:postal_code],
        description: value[:description],
        amenities: value[:amenities],
        images: value[:images],
        booking_conditions: value[:booking_conditions]
      }
    end
  end

  def get_longest_string(old_str, new_str)
    return '' if old_str.nil?
    return old_str if new_str.nil?

    old_str.size < new_str.size ? new_str : old_str
  end

  def combine_hash(old_hash, new_hash)
    return {} if old_hash.nil?
    return new_hash if old_hash.empty?

    new_hash.each do |key, value|
      old_hash[key] = if old_hash.key? key
                        old_hash[key] + value
                      else
                        value
                      end
    end

    old_hash
  end

  def combine_images(old, new)
    return {} if old.nil?
    return new if old.empty?

    debugger
    new
  end

  def merge_data
    merged_data = {}
    @data.each do |hash|
      if merged_data.key?(hash[:id]) && merged_data.dig(hash[:id], :destination_id)
        # take the longest string
        merged_data[hash[:id]][:name] = get_longest_string(merged_data[hash[:id]][:name], hash[:name])
        merged_data[hash[:id]][:address] = get_longest_string(merged_data[hash[:id]][:address], hash[:address])
        merged_data[hash[:id]][:city] = get_longest_string(merged_data[hash[:id]][:city], hash[:city])
        merged_data[hash[:id]][:country] = get_longest_string(merged_data[hash[:id]][:country], hash[:country])
        merged_data[hash[:id]][:description] =
          get_longest_string(merged_data[hash[:id]][:description], hash[:description])

        # take the present lat, lng
        merged_data[hash[:id]][:lat] = hash[:lat].present? ? hash[:lat] : merged_data[hash[:id]][:lat]
        merged_data[hash[:id]][:lng] = hash[:lng].present? ? hash[:lng] : merged_data[hash[:id]][:lng]

        # combine hash by keys
        merged_data[hash[:id]][:amenities] = combine_hash(merged_data[hash[:id]][:amenities], hash[:amenities])
        merged_data[hash[:id]][:images] = combine_images(merged_data[hash[:id]][:images], hash[:images])

        # merge booking_condition
        merged_data[hash[:id]][:booking_conditions] =
          merged_data[hash[:id]][:booking_conditions].nil? ? hash[:booking_conditions] : merged_data[hash[:id]][:booking_conditions] + hash[:booking_conditions]
      else
        merged_data[hash[:id]] =
          hash.slice(:destination_id, :name, :lat, :lng, :address, :city, :country, :postal_code, :description,
                     :amenities, :images, :booking_conditions, :images)
      end
    end

    @data = merged_data
  end

  def call_api(endpoint)
    url = @base_url + endpoint
    begin
      response = JSON.parse(RestClient.get(url))
    rescue StandardError => e
      puts 'TODO: raise error'
    end
    @data += send("process_#{endpoint}", response)
  end

  def process_acme(response)
    response.map do |hash|
      hash = hash
             .transform_keys(&:underscore) # standardize key names
             .transform_keys('latitude' => :lat, 'longitude' => :lng)
             .deep_symbolize_keys

      hash.map do |key, value|
        hash[key] = value.strip if value.is_a?(String) && key != :id # clean string values
      end

      hash.delete(:facilities) # remove facilities value (unstructured data)
      hash
    end
  end

  def process_patagonia(response)
    response.map do |hash|
      hash = hash
             .transform_keys(&:underscore) # standardize key names
             .transform_keys('destination' => :destination_id, 'info' => :description)
             .deep_symbolize_keys

      hash.map do |key, value|
        hash[key] = value.strip if value.is_a?(String) && key != :id
      end

      hash.delete(:amenities) # remove amenities value (unstructured data)

      # sync images value
      new_images = hash[:images].deep_transform_keys do |key|
        key == :url ? :link : key
      end

      hash[:images] = new_images
      hash
    end
  end

  def process_paperflies(response)
    response.map do |hash|
      hash = hash
             .transform_keys(&:underscore) # standardize key names
             .transform_keys('hotel_id' => :id, 'hotel_name' => :name, 'details' => :description)
             .deep_symbolize_keys

      hash.map do |key, value|
        hash[key] = value.strip if value.is_a?(String) && key != :id
      end

      hash[:address] = hash[:location][:address]
      hash[:country] = hash[:location][:country]
      hash.delete(:location) # remove amenities value (unstructured data)

      # sync images value
      new_images = hash[:images].deep_transform_keys do |key|
        key == :caption ? :description : key
      end

      hash[:images] = new_images
      hash
    end
  end
end
