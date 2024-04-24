require 'geocoder'

class HotelProcurer
  attr_reader :data
  attr_accessor :endpoints

  def initialize
    # assuming that this data is coming from a table
    # with this structure

    # Supplier
      # @name: String,
      # @endpoint: String
      # @active: Boolean

    # and eventually we're plucking on the names
    @suppliers = [
      {name: 'acme', endpoint: 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme'},
      {name: 'paperflies', endpoint: 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/paperflies'},
      {name: 'patagonia', endpoint: 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/patagonia'},
    ]
  end

  def call
    @suppliers.map do |supplier|
      procure_data(supplier)
    end

    fill_lat_lng
    refresh_hotels_cache
  end

  private

  # in case the lat and lng are still nil at the end of the procurement
  def fill_lat_lng
    Hotel.where(lat: nil, lng: nil).each do |hotel|
      hotel.update(
        lat: geocode_name("#{hotel.name}, #{hotel.country}")&.first,
        lng: geocode_name("#{hotel.name}, #{hotel.country}")&.first
      )
    end
  end

  def procure_data(supplier)
    Procurer::Service.new(supplier).call
  end

  def refresh_hotels_cache
    Hotel.all.each do |hotel|
      cache_key = ['hotel', hotel]
      Rails.cache.delete(cache_key)
    end
  end

  # util methods

  def geocode_name(location)
    Geocoder.search(location)&.first&.coordinates
  end
end
