FactoryBot.define do
  factory :buyer_application do
    association :buyer
    state 'created'
    application_body 'Text'

    trait :created do
      state 'created'
    end
    trait :awaiting_assignment do
      state 'awaiting_assignment'
    end
    trait :assigned do
      state 'assigned'
    end

    factory :created_buyer_application, traits: [:created]
    factory :awaiting_assignment_buyer_application, traits: [:awaiting_assignment]
    factory :assigned_buyer_application, traits: [:assigned]
  end
end
