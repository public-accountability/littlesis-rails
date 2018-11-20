#!/usr/bin/env ruby
# frozen_string_literal: true

SfGuardUserProfile.find_each do |sf_guard_user_profile|
  user = sf_guard_user_profile&.sf_guard_user&.user
  next if user.blank?

  if user.user_profile.nil?

    ColorPrinter.print_green "Creating User Profile for #{user.username}"

    user.create_user_profile!(name_first: sf_guard_user_profile.name_first,
                              name_last: sf_guard_user_profile.name_last,
                              reason: sf_guard_user_profile.reason,
                              location: sf_guard_user_profile.location)

  else
    ColorPrinter.print_magenta "A User Profile already exists for #{user.username}"
  end
end
