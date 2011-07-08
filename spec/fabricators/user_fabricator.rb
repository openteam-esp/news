# encoding: utf-8

Fabricator(:user) do
  email "example@mail.no"
  name "Иван Встанькин"
  password '123123'
  password_confirmation '123123'
end
