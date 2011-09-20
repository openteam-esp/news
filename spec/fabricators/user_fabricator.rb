# encoding: utf-8

require 'ryba'
require 'forgery'

Fabricator(:user) do
  name { Ryba::Name.full_name }
  email { | user | "#{user.name.parameterize}@#{Forgery(:internet).domain_name}" }
  password { Forgery(:basic).password }
  password_confirmation { |user| user.password }
end
