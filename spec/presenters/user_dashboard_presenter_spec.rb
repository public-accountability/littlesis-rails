# frozen_string_literal: true

require 'rails_helper'

describe UserDashboardPresenter do
  it 'initalizes with user' do
    user = build(:user)
    expect(UserDashboardPresenter.new(user).__getobj__).to be user
  end
end
