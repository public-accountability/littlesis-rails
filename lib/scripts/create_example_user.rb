#!/usr/bin/env -S rails runner

require 'factory_bot_rails'

unless Rails.env.development?
  raise "#{__FILE__} should only be run in the development environment"
end

email = Faker::Internet.email
password = 'password'

user = FactoryBot.create(:user, email: email)

user.create_user_profile!(name_first: Faker::Name.first_name,
                          name_last: Faker::Name.last_name,
                          reason: Faker::Music::Prince.lyric)

user.reset_password(password, password)
user.add_ability!(:edit, :list)

ColorPrinter.print_blue <<-MSG

  new user created:
  ----------------------
  email: #{email}
  password: #{password}
  ----------------------

MSG
