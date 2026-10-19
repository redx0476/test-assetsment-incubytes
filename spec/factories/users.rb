FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "hr#{n}@acme.test" }
    password { "password123" }
    role { :hr_manager }
  end
end
