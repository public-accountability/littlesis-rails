# frozen_string_literal: true

require 'rails_helper'

describe UserPresenter do
  describe 'show_private?' do
    let(:user) { create(:really_basic_user) }
    let(:current_user) { create(:really_basic_user) }
    let(:admin_user) { create_admin_user }

    context 'as same user' do
      specify do
        expect(UserPresenter.new(user, current_user: user).show_private?).to be true
      end
    end

    context 'as another user' do
      specify do
        expect(UserPresenter.new(user, current_user: current_user).show_private?).to be false
      end
    end

    context 'as admin' do
      specify do
        expect(UserPresenter.new(user, current_user: admin_user).show_private?).to be true
      end
    end

    context 'current_user is nil' do
      specify do
        expect(UserPresenter.new(user).show_private?).to be false
      end
    end
  end

  describe '#ability_display' do
    subject(:user_presenter) { UserPresenter.new(user) }

    let(:user) { build(:user, abilities: UserAbilities.new(:edit, :delete)) }

    it 'returns yes for "edit"' do
      expect(user_presenter.ability_display(:edit)).to eq 'Yes'
    end

    it 'returns yes for "delete"' do
      expect(user_presenter.ability_display(:delete)).to eq 'Yes'
    end

    it 'returns no for "bulk"' do
      expect(user_presenter.ability_display(:bulk)).to eq 'No'
    end

    it 'returns no for "admin"' do
      expect(user_presenter.ability_display(:admin)).to eq 'No'
    end
  end

  describe 'member_since' do
    let(:user) { build(:user, created_at: Time.zone.parse('2009-02-01')) }

    specify do
      expect(UserPresenter.new(user).member_since).to eql "member since February 2009"
    end
  end
end
