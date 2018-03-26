require 'rails_helper'

describe UserPresenter do
  let(:user) { create(:really_basic_user) }
  describe 'show_private?' do
    let(:current_user) { create(:really_basic_user) }
    let(:admin_user) { create(:admin_user) }

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

  describe 'member_since' do
    before do
      user.update_column(:created_at, Time.zone.parse('2009-02-01'))
    end

    specify do
      expect(UserPresenter.new(user).member_since).to eql "member since February 2009"
    end
  end
end
