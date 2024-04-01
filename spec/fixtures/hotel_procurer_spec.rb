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
        all_symbolized = hash.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_symbolized).to be_truthy
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
      mock_response_path = Rails.root.join('spec/fixtures/acme_response.json')
      JSON.parse(File.read(mock_response_path))
    end
    let(:output) { described_class.new.send(:process_acme, payload) }
    it 'gives back all the correct keys' do
      output.each do |hash|
        # have all the keys except facilities
        all_symbolized = hash.keys.all? { |key| key.is_a?(Symbol) }
        expect(all_symbolized).to be_truthy
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
end
