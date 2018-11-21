#!/usr/bin/env ruby
# frozen_string_literal: true

SfGuardUserProfile.find_each do |sf_guard_user_profile|
  user = sf_guard_user_profile&.sf_guard_user&.user
  next if user.blank?

  if user.user_profile.nil?

    ColorPrinter.print_green "Creating User Profile for #{user.username}"

    if sf_guard_user_profile.reason.blank? || sf_guard_user_profile.reason.split(' ').length < 2
      reason = 'default reason'
    else
      reason = sf_guard_user_profile.reason
    end

    user.create_user_profile!(name_first: sf_guard_user_profile.name_first,
                              name_last: sf_guard_user_profile.name_last,
                              reason: reason,
                              location: sf_guard_user_profile.location)

  else
    ColorPrinter.print_magenta "A User Profile already exists for #{user.username}"
  end
end
