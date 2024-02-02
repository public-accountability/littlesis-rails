#!/usr/bin/env -S rails runner

require 'factory_bot_rails'

unless Rails.env.development?
  raise "#{__FILE__} should only be run in the development environment"
end

email = Faker::Internet.email
password = 'password'

user = FactoryBot.create(:user, email: email)

user.create_user_profile!(name: Faker::Name.name, reason: Faker::Music::Prince.lyric)

user.reset_password(password, password)

user.update role: 'editor'

ColorPrinter.print_blue <<-MSG

  new user created:
  ----------------------
  username: #{user.username}
  email: #{email}
  password: #{password}
  ----------------------

MSG
