require 'geocoder'

class HotelProcurer
  def initialize
    @base_url = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/'
    # when we need to add/remove a supplier, we can adjust this array
    @endpoints = %w[
      acme
      patagonia
      paperflies
    ]
    @data = []
  end

  def call
    @endpoints.each do |endpoint|
      combine_data(endpoint) # combine all data based on the api responses
    end

    deduplicate_data
    cleanup_data
  end

  private

  def deduplicate_data
    merged_data = {}
    @data.each do |hash|
      key = hash[:id]
      existing_data = merged_data[key]

      if existing_data && existing_data[:destination_id] == hash[:destination_id]
        merge_existing_data(existing_data, hash, key)
      else
        merged_data[key] =
          hash.slice(:destination_id, :name, :lat, :lng, :address, :city, :country, :postal_code, :description, :amenities,
                     :images, :booking_conditions)
      end
    end

    @data = merged_data
  end

  def merge_existing_data(existing_data, new_data, _key)
    merge_longest_strings(existing_data, new_data, %i[name address city country description])
    merge_present_values(existing_data, new_data, %i[lat lng])
    if new_data.key?(:amenities)
      existing_data[:amenities] =
        combine_hash(existing_data[:amenities], new_data[:amenities])
    end
    existing_data[:images] = combine_images(existing_data[:images], new_data[:images]) if new_data.key?(:images)
    existing_data[:booking_conditions] ||= []
    existing_data[:booking_conditions] += new_data[:booking_conditions] if new_data.key?(:booking_conditions)
    existing_data
  end

  def merge_longest_strings(existing_data, new_data, fields)
    fields.each do |field|
      existing_data[field] = get_longest_string(existing_data[field], new_data[field])
    end
  end

  def merge_present_values(existing_data, new_data, fields)
    fields.each do |field|
      existing_data[field] = new_data[field].presence || existing_data[field]
    end
  end

  def combine_data(endpoint)
    url = @base_url + endpoint
    response = JSON.parse(RestClient.get(url))
    @data += send("process_#{endpoint}", response)
  rescue StandardError
    raise StandardError, 'Invalid API endpoints provided!'
  end

  def cleanup_data
    @data.map do |key, value|
      coordinates = geocode_name("#{value[:name]} #{value[:country]}")&.first&.coordinates

      {
        id: key,
        destination_id: value[:destination_id],
        name: value[:name],
        lat: coordinates&.first,
        lng: coordinates&.second,
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

  # different processor strategies according the supplier endpoints
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

  # util methods
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
    return new if old.nil?

    old&.deep_merge!(new) do |_key, v1, v2|
      if v1.is_a?(Array) && v2.is_a?(Array)
        (v1 + v2).uniq # if different link, merge the array
      else
        v1 || v2 # take whichever is not nil
      end
    end
  end

  def geocode_name(location)
    Geocoder.search(location)
  end
end
