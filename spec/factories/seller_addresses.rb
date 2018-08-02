FactoryBot.define do
  factory :seller_address do
    address '123 Test Street'
    suburb 'Sydney'
    state 'nsw'
    postcode '2000'
    country 'AU'

    initialize_with { new(attributes) }
  end
end
