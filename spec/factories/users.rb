FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    cpf { "12345678900" }
    password { "password" }
  end
end
