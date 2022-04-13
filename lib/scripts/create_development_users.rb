#!/usr/bin/env -S rails runner

unless Rails.env.development?
  raise "#{__FILE__} should only be run in the development environment"
end

[
  %w[user user@dev.littlesis.org user],
  %w[editor editor@dev.littlesis.org editor],
  %w[collaborator collaborator@dev.littlesis.org collaborator],
  %w[admin admin@dev.littlesis.org admin]
].each do |(username, email, role)|
  password = 'password'
  user = User.create!(username: username, email: email, role: role)
  user.update_columns(created_at: 1.week.ago, confirmed_at: 1.hour.ago)
  user.create_user_profile!(name: Faker::Name.name, reason: Faker::Music::Prince.lyric)
  user.reset_password(password, password)
  ColorPrinter.print_green "created #{username} with password #{password}"
end
