#!/usr/bin/env ruby

unless Rails.env.development?
  raise "#{__FILE__} should only be run in the development environment"
end

email = Faker::Internet.email
password = 'password'

sf_user = FactoryBot.create(:sf_guard_user)
user = FactoryBot.create(:user, sf_guard_user_id: sf_user.id, email: email)
user.reset_password(password, password)
user.add_ability!(:edit, :list)

ColorPrinter.print_blue <<-MSG

  new user created:
  ----------------------
  email: #{email}
  password: #{password}
  ----------------------

MSG
