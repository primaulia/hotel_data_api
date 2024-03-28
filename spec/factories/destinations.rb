FactoryBot.define do
  factory :destination do
    name { 'Japan' }

    factory :destination_with_hotels do
      transient do
        hotels_count { 3 }
      end

      after(:create) do |destination, evaluator|
        create_list(:hotel, evaluator.hotels_count, destination:)

        destination.reload
      end
    end
  end
end
