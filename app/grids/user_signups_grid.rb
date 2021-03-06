# frozen_string_literal: true

class UserSignupsGrid < BaseGrid
  scope do
    User
      .includes(:user_profile)
      .where("confirmed_at is not null")
      .order(created_at: :desc)
  end

  column(:username, header: "Username", html: true, order: false) do |user|
    link_to user.username, "/users/#{user.username}"
  end

  column(:confirmed, header: "Joined On", order: false) do |user|
    user.created_at.strftime('%m/%d/%Y')
  end

  column(:why_they_joined, header: "Why they joined", order: false) do |user|
    user.user_profile&.reason
  end
end
