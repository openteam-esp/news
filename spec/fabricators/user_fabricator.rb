# encoding: utf-8

Fabricator(:user) do
  email { Fabricate.sequence(:email) { |i| "user#{i}@example.com" } }
  name "Иван Встанькин"
  password '123123'
  password_confirmation '123123'
end
