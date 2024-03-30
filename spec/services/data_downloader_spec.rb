require 'rails_helper'

RSpec.describe DataDownloader do
  describe 'Happy flow' do
    before(:each) do
      mock_response_path = Rails.root.join('spec/fixtures/api_response.json')
      mock_response_body = JSON.parse(File.read(mock_response_path)).map(&:deep_symbolize_keys)

      allow_any_instance_of(HotelProcurer).to receive(:call).and_return(mock_response_body)
    end

    let(:data) { described_class.new.data.first }

    describe '__create_destinations' do
      let(:destination) { create(:destination) }
      it 'creates a destination based on the given destination_id' do
        id = data[:destination_id]
        expect { described_class.new.send(:create_destination, id) }.to change(Destination, :count).by(1)
        expect(Destination.first.id).to eq(id)
      end

      it 'doesnt create a new one if the destination already exists' do
        id = data[:destination_id]
        destination.update_columns(id:)
        expect { described_class.new.send(:create_destination, id) }.not_to change(Destination, :count)
      end

      it 'raise an error if the destination cannot be created' do
        expect { described_class.new.send(:create_destination, nil) }.to raise_error(StandardError)
      end
    end

    describe '__create_hotel' do
      let(:destination) { create(:destination) }
      let(:hotel) { create(:hotel, destination:) }
      it 'creates a hotel based on the given data' do
        described_class.new.send(:create_destination, data[:destination_id])
        expect { described_class.new.send(:create_hotel, data) }.to change(Hotel, :count).by(1)

        created_hotel = Hotel.first
        expect(created_hotel.slug).to eq(data[:id])
        expect(created_hotel.name).to eq(data[:name])
        expect(created_hotel.address).to eq(data[:address])
      end

      it 'doesnt create a new one if the hotel already exists' do
        data[:destination_id] = destination.id
        hotel.update_columns(slug: data[:id])
        expect { described_class.new.send(:create_hotel, data) }.not_to change(Hotel, :count)
        expect(Hotel.first.destination_id).to eq(destination.id)
      end

      it 'raise an error if the hotel cannot be created' do
        data[:destination_id] = nil
        expect { described_class.new.send(:create_hotel, data) }.to raise_error(StandardError)
      end
    end

    describe '__setup_amenities' do
      let(:destination) { create(:destination) }
      let(:hotel) { create(:hotel, destination:) }
      let!(:amenity) { create(:amenity, hotel:) }

      it 'creates amenities record based for the given hotel' do
        expect do
          described_class.new.send(:setup_amenities, data[:amenities],
                                   hotel)
        end.to change(Amenity, :count).by(data[:amenities].values.map(&:count).sum - 1)
        expect(Amenity.first.hotel_id).to eq(hotel.id)
      end

      it 'doesn\'t recreate a new amenities record if it already exist' do
        given_amenities = {
          general: [
            'aircon',
            'business center'
          ]
        }
        expect do
          described_class.new.send(:setup_amenities, given_amenities,
                                   hotel.reload)
        end.to change(Amenity, :count).by(1)
        expect(Amenity.first.hotel_id).to eq(hotel.id)
        expect(hotel.reload.amenities.count).to eq(2)
        expect(hotel.amenities.pluck(:name)).to match_array(['aircon', 'business center'])
      end

      it 'cleans all the unused amenities' do
        given_amenities = {
          general: [
            'xxx'
          ]
        }

        described_class.new.send(:setup_amenities, given_amenities,
                                 hotel.reload)
        expect(hotel.amenities.count).to eq(1)
      end

      it 'raise an error if the amenity cannot be created' do
        hotel = nil
        expect { described_class.new.send(:setup_amenities, hotel) }.to raise_error(StandardError)
      end
    end

    describe '__setup_images' do
      let(:destination) { create(:destination) }
      let(:hotel) { create(:hotel, destination:) }
      let!(:image) { create(:image, hotel:) }

      it 'creates images record based for the given hotel' do
        expect do
          described_class.new.send(:setup_images, data[:images],
                                   hotel)
        end.to change(Image, :count).by(data[:images].values.map(&:count).sum - 1)
        expect(Image.first.hotel_id).to eq(hotel.id)
      end

      it 'doesn\'t recreate image if it already exists' do
        given_images = {
          rooms: [
            {
              link: 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg',
              description: 'Double room'
            },
            {
              link: 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i94_m.jpg',
              description: 'Bathroom'
            }
          ]
        }

        expect do
          described_class.new.send(:setup_images, given_images,
                                   hotel)
        end.to change(Image, :count).by(1)
        expect(Image.first.hotel_id).to eq(hotel.id)
        expect(hotel.reload.images.count).to eq(2)
        expect(hotel.images.pluck(:link)).to match_array(['https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i93_m.jpg', 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/i94_m.jpg'])
      end

      it 'cleans all the unused images' do
        given_images = {
          rooms: [
            {
              link: 'https://d2ey9sqrvkqdfs.cloudfront.net/Sjym/xxx_m.jpg',
              description: 'Single room'
            }
          ]
        }

        described_class.new.send(:setup_images, given_images,
                                 hotel.reload)
        expect(hotel.images.count).to eq(1)
      end

      it 'raise an error if the image cannot be created' do
        hotel = nil
        expect { described_class.new.send(:setup_images, hotel) }.to raise_error(StandardError)
      end
    end

    describe '__setup_booking_conditions' do
      let(:destination) { create(:destination) }
      let(:hotel) { create(:hotel, destination:) }
      let!(:booking_condition) { create(:booking_condition, hotel:) }

      it 'creates a booking condition record based for the given hotel' do
        expect do
          described_class.new.send(:setup_booking_conditions, data[:booking_conditions],
                                   hotel)
        end.to change(BookingCondition, :count).by(data[:booking_conditions].size - 1)
        expect(BookingCondition.first.hotel_id).to eq(hotel.id)
      end

      it 'doesn\'t recreate booking condition if it already exists' do
        given_conditions = [
          'WiFi is available in all areas and is free of charge.',
          'Random conditions'
        ]

        expect do
          described_class.new.send(:setup_booking_conditions, given_conditions,
                                   hotel)
        end.to change(BookingCondition, :count).by(1)
        expect(BookingCondition.first.hotel_id).to eq(hotel.id)
        expect(hotel.reload.booking_conditions.count).to eq(2)
        expect(hotel.booking_conditions.first.condition).to eq('WiFi is available in all areas and is free of charge.')
      end

      it 'cleans all the unused images' do
        given_conditions = ['Free private parking is possible on site (reservation is not needed).']

        described_class.new.send(:setup_booking_conditions, given_conditions,
                                 hotel.reload)
        expect(hotel.booking_conditions.count).to eq(1)
      end

      it 'raise an error if the booking condition cannot be created' do
        hotel = nil
        expect { described_class.new.send(:setup_images, hotel) }.to raise_error(StandardError)
      end
    end

    describe '#call' do
      it 'creates the appropriate model according to the api response' do
        # Procure the data and save it to the db
        expect { described_class.new.call }.to change {
                                                 [Destination.count, Hotel.count, Amenity.count, Image.count,
                                                  BookingCondition.count]
                                               }.by([2, 3, 17, 6, 11]) # based on the mock api response

        # if it's called again, nothing will change
        expect { described_class.new.call }.not_to change {
                                                     [Destination.count, Hotel.count, Amenity.count, Image.count,
                                                      BookingCondition.count]
                                                   }
      end
    end
  end
end
