require 'rails_helper'

RSpec.describe 'Hotels', type: :request do
  describe 'root' do
    it 'returns http success' do
      get '/'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /api/hotels' do
    let!(:destinations) { create_list(:destination_with_hotels, 2) }
    let!(:hotels) { Hotel.all }

    it 'returns http success, with a json body' do
      get '/api/hotels'
      expect(response).to have_http_status(:success)
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns a correct json if filtered by slug' do
      first_slug = hotels.first.slug
      last_slug = hotels.last.slug
      get "/api/hotels?hotels=#{first_slug}"
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(1)
      parsed_body.each_with_index do |hotel, index|
        expect(hotel['id']).to eq(hotels[index].slug)
      end

      get "/api/hotels?hotels=#{first_slug},#{last_slug}"
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(2)
    end

    it 'returns a correct json if filtered by destination' do
      get '/api/hotels?destinations=1'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(destinations.first.hotels.size)

      get '/api/hotels?destinations=1,2'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(hotels.size)
    end

    it 'returns a correct json if filtered by hotels and destination' do
      first_slug = hotels.first.slug
      last_slug = hotels.last.slug

      get "/api/hotels?hotels=#{first_slug},#{last_slug}"
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(2)

      get "/api/hotels?hotels=#{first_slug},#{last_slug}&destinations=1"
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.size).to eq(1)
    end
  end
end
