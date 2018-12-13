# frozen_string_literal: true

# rubocop:disable RSpec/VerifiedDoubles, RSpec/MessageChain, RSpec/MultipleExpectations

require 'rails_helper'

describe UserDashboardPresenter do
  let(:user) { build(:user) }

  it 'initalizes with user' do
    expect(UserDashboardPresenter.new(user).user).to be user
  end

  def page_double(n)
    double('page').tap do |d|
      expect(d). to receive(:page).with(n).and_return(double(:per => []))
    end
  end

  it 'uses 1 as page defaults' do
    expect(user).to receive_message_chain('lists.order').and_return(page_double(1))
    expect(user).to receive_message_chain('network_maps.order').and_return(page_double(1))
    expect(user).to receive(:edited_entities)
    UserDashboardPresenter.new(user)
  end

  it 'retrives lists, maps, and edited_entities' do
    expect(user).to receive_message_chain('lists.order').and_return(page_double(2))
    expect(user).to receive_message_chain('network_maps.order').and_return(page_double(3))
    expect(user).to receive(:edited_entities)
    UserDashboardPresenter.new(user, list_page: 2, map_page: 3)
  end
end

# rubocop:enable RSpec/VerifiedDoubles, RSpec/MessageChain, RSpec/MultipleExpectations
