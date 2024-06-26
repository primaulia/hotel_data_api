require 'rails_helper'

RSpec.describe HotelProcurer do
  describe '__process_acme' do
    let(:payload) do
      mock_response_path = Rails.root.join('spec/fixtures/acme_response.json')
      JSON.parse(File.read(mock_response_path))
    end
    let(:output) { described_class.new.send(:process_acme, payload) }
    it 'gives back all the correct keys' do
      output.each do |hash|
        # have all the keys except facilities
        expect(hash.keys).to match_array(%i[id destination_id name lat lng address city country postal_code
                                            description])
        expect(hash.keys).not_to include(:facilities)
      end
    end

    it 'symbolized all the keys' do
      output.each do |hash|
        all_symbolized = hash.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_symbolized).to be_truthy
      end
    end

    it 'stripped all the strings' do
      output.each do |hash|
        hash.values.grep(String).all? do |str|
          expect(str).to eq(str.strip)
        end
      end
    end
  end

  describe '__process_patagonia' do
    let(:payload) do
      mock_response_path = Rails.root.join('spec/fixtures/patagonia_response.json')
      JSON.parse(File.read(mock_response_path))
    end
    let(:output) { described_class.new.send(:process_patagonia, payload) }
    it 'gives back all the correct keys' do
      output.each do |hash|
        # have all the keys except amenities
        expect(hash.keys).to match_array(%i[id destination_id name lat lng address
                                            description images])
        expect(hash.keys).not_to include(:amenities)
      end
    end

    it 'symbolized all the keys' do
      output.each do |hash|
        all_symbolized = hash.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_symbolized).to be_truthy
      end
    end

    it 'symbolized all the images keys' do
      output.each do |hash|
        images = hash[:images]
        all_images_symbolized = images.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_images_symbolized).to be_truthy
      end
    end

    it 'standardized the images keys' do
      output.each do |hash|
        images = hash[:images]
        images.each do |_key, value|
          value.each do |img_hash|
            expect(img_hash.keys).to match_array(%i[description link])
          end
        end
      end
    end

    it 'stripped all the strings' do
      output.each do |hash|
        hash.values.grep(String).all? do |str|
          expect(str).to eq(str.strip)
        end
      end
    end
  end

  describe '__process_paperflies' do
    let(:payload) do
      mock_response_path = Rails.root.join('spec/fixtures/paperflies_response.json')
      JSON.parse(File.read(mock_response_path))
    end
    let(:output) { described_class.new.send(:process_paperflies, payload) }
    it 'gives back all the correct keys' do
      output.each do |hash|
        # have all the keys except amenities
        expect(hash.keys).to match_array(%i[id destination_id name address
                                            description images amenities booking_conditions country])
        expect(hash.keys).not_to include(:location)
      end
    end

    it 'symbolized all the keys' do
      output.each do |hash|
        all_symbolized = hash.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_symbolized).to be_truthy
      end
    end

    it 'symbolized all the images keys' do
      output.each do |hash|
        images = hash[:images]
        all_images_symbolized = images.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_images_symbolized).to be_truthy
      end
    end

    it 'standardized the images keys' do
      output.each do |hash|
        images = hash[:images]
        images.each do |_key, value|
          value.each do |img_hash|
            expect(img_hash.keys).to match_array(%i[description link])
          end
        end
      end
    end

    it 'stripped all the strings' do
      output.each do |hash|
        hash.values.grep(String).all? do |str|
          expect(str).to eq(str.strip)
        end
      end
    end
  end

  describe '__get_longest_string' do
    it 'returns empty string if the first argument is nil' do
      expect(described_class.new.send(:get_longest_string, nil, 'hello')).to eq('')
    end

    it 'returns first argument if the second argument is nil' do
      expect(described_class.new.send(:get_longest_string, 'hello', nil)).to eq('hello')
    end

    it 'returns longest string out of the two arguments given' do
      expect(described_class.new.send(:get_longest_string, 'hello', 'helloooo')).to eq('helloooo')
      expect(described_class.new.send(:get_longest_string, 'helloooo', 'hello')).to eq('helloooo')
    end

    it 'returns the second argument if it has the same length with the first argument' do
      expect(described_class.new.send(:get_longest_string, 'x', 'y')).to eq('y')
      expect(described_class.new.send(:get_longest_string, 'y', 'x')).to eq('x')
    end

    it 'raises an error if any arguments are not nil and not string' do
      expect { described_class.new.send(:get_longest_string, '', []) }.to raise_error(ArgumentError)
      expect { described_class.new.send(:get_longest_string, 1, 'hello') }.to raise_error(ArgumentError)
    end
  end

  describe '__merge_hash' do
    let(:amenity1) do
      {
        general: [
          'outdoor pool',
          'indoor pool',
          'business center',
          'childcare'
        ],
        room: ['tv', 'coffee machine', 'kettle', 'hair dryer', 'iron']
      }
    end
    let(:amenity2) do
      {
        general: [
          'outdoor pool',
          'indoor pool',
          'business center',
          'gym'
        ],
        room: ['tv']
      }
    end

    let(:images1) do
      {
        rooms: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg',
            description: 'Double room'
          },
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg',
            description: 'Double room'
          }
        ],
        site: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg',
            description: 'Front'
          }
        ]
      }
    end
    let(:images2) do
      {
        rooms: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg',
            description: 'Double room'
          },
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg',
            description: 'Bathroom'
          }
        ],
        amenities: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg',
            description: 'RWS'
          },
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg',
            description: 'Sentosa Gateway'
          }
        ]
      }
    end
    let(:images_merged) do
      {
        rooms: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/2.jpg',
            description: 'Double room'
          },
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/3.jpg',
            description: 'Double room'
          },
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/4.jpg',
            description: 'Bathroom'
          }
        ],
        site: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/1.jpg',
            description: 'Front'
          }
        ],
        amenities: [
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/0.jpg',
            description: 'RWS'
          },
          {
            link: 'https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg',
            description: 'Sentosa Gateway'
          }
        ]
      }
    end

    it 'returns second argument if the first argument is nil' do
      second_argument = { hello: 'world' }
      expect(described_class.new.send(:merge_hash, nil, second_argument)).to eq(second_argument)
    end

    it 'raises an error if any arguments are not nil and not string' do
      expect { described_class.new.send(:merge_hash, {}, '') }.to raise_error(ArgumentError)
      expect { described_class.new.send(:merge_hash, 0, { hello: 'world' }) }.to raise_error(ArgumentError)
    end

    it 'any of the arguments are nil, returns the one that\'s not' do
      hashed_argument = { hello: 'world' }
      expect(described_class.new.send(:merge_hash, hashed_argument, nil)).to eq(hashed_argument)
    end

    it 'merges the amenities' do
      result = {
        general: [
          'outdoor pool',
          'indoor pool',
          'business center',
          'childcare',
          'gym'
        ],
        room: ['tv', 'coffee machine', 'kettle', 'hair dryer', 'iron']
      }

      expect(described_class.new.send(:merge_hash, amenity1, amenity2)).to eq(result)
    end

    it 'merges the images' do
      expect(described_class.new.send(:merge_hash, images1, images2)).to eq(images_merged)
    end
  end

  describe 'service flow' do
    let(:acme_response_path) { Rails.root.join('spec/fixtures/acme_response.json') }
    let(:acme_response) { File.read(acme_response_path) }
    let(:cleaned_acme_path) { Rails.root.join('spec/fixtures/cleaned_acme.json') }
    let(:cleaned_acme) { JSON.parse(File.read(cleaned_acme_path)).map!(&:deep_symbolize_keys) }

    let(:patagonia_response_path) { Rails.root.join('spec/fixtures/patagonia_response.json') }
    let(:patagonia_response) { File.read(patagonia_response_path) }
    let(:cleaned_patagonia_path) { Rails.root.join('spec/fixtures/cleaned_patagonia.json') }
    let(:cleaned_patagonia) { JSON.parse(File.read(cleaned_patagonia_path)).map!(&:deep_symbolize_keys) }

    let(:paperflies_response_path) { Rails.root.join('spec/fixtures/paperflies_response.json') }
    let(:paperflies_response) { File.read(paperflies_response_path) }
    let(:cleaned_paperflies_path) { Rails.root.join('spec/fixtures/cleaned_paperflies.json') }
    let(:cleaned_paperflies) { JSON.parse(File.read(cleaned_paperflies_path)).map!(&:deep_symbolize_keys) }

    let(:final_data_path) { Rails.root.join('spec/fixtures/api_response.json') }
    let(:final_data_body) { JSON.parse(File.read(final_data_path)).map(&:deep_symbolize_keys) }

    let(:instance) { described_class.new }

    before(:each) do
      stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/acme')
        .to_return(status: 200, body: acme_response, headers: {})
      stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/patagonia')
        .to_return(status: 200, body: patagonia_response, headers: {})
      stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/paperflies')
        .to_return(status: 200, body: paperflies_response, headers: {})
      Geocoder.configure(lookup: :test)
    end

    describe '__combine_data' do
      it 'combined the data based on the endpoints given' do
        combined_data = instance.send(:combine_data, 'acme')
        expect(combined_data).to eq(cleaned_acme)

        combined_data += instance.send(:combine_data, 'patagonia')
        expect(combined_data).to eq(cleaned_acme + cleaned_patagonia)
      end

      it 'calling an API that has no processor will raise an error' do
        stub_request(:get, 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers/foo')
          .to_return(status: 404)

        expect { instance.send(:combine_data, 'foo') }.to raise_error(StandardError)
      end
    end

    describe '__deduplicate_data' do
      it 'deduplicate the data that already exist from the previous processing operation' do
        combined_data = instance.send(:combine_data, 'acme')
        combined_data += instance.send(:combine_data, 'patagonia')
        deduped_data = instance.send(:deduplicate_data, combined_data)
        unique_keys = (cleaned_acme.pluck(:id) + cleaned_patagonia.pluck(:id)).uniq
        expect(deduped_data.keys).to eq(unique_keys)
      end
    end

    describe '__cleanup_data' do
      it 'cleaned up different fields' do
        Geocoder::Lookup::Test.add_stub(
          'InterContinental Singapore Robertson Quay, SG',
          [
            { 'coordinates': [35.6927125, 139.69124935043257] }
          ]
        )
        acme_data = instance.send(:combine_data, 'acme')
        deduped_acme_data = instance.send(:deduplicate_data, acme_data)
        data = instance.send(:cleanup_data, deduped_acme_data)
        data.each do |hash|
          expect(hash[:name]).to eq(deduped_acme_data[hash[:id]][:name].titleize)
          expect(hash[:address]).to eq(deduped_acme_data[hash[:id]][:address].split(' ').map(&:capitalize).join(' '))
          expect(hash[:city]).to eq(deduped_acme_data[hash[:id]][:city].capitalize)
          expect(hash[:country]).to eq(deduped_acme_data[hash[:id]][:country].capitalize)
          expect(hash[:lat]).not_to be_nil
          expect(hash[:lng]).not_to be_nil
        end
      end
    end

    describe '#call' do
      it 'procures data from three different suppliers' do
        Geocoder::Lookup::Test.add_stub(
          'InterContinental Singapore Robertson Quay, Singapore',
          [
            { 'coordinates': [35.6927125, 139.69124935043257] }
          ]
        )
        expect(instance.call.size).to eq(final_data_body.size)
        instance.call.each_with_index do |hash, index|
          expect(hash.keys).to match_array(final_data_body[index].keys)
        end
      end
    end
  end
end
