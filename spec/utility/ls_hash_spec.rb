require 'rails_helper'

describe LsHash do
  subject { LsHash.new }
  it { is_expected.to be_a ActiveSupport::HashWithIndifferentAccess }

  describe 'with_user_user' do
    let(:user) { create_really_basic_user }

    it 'accepts integers' do
      expect(subject.with_last_user(123)).to eql LsHash.new(last_user_id: 123)
    end

    it 'accepts strings' do
      expect(subject.with_last_user('123')).to eql LsHash.new(last_user_id: 123)
    end

    it 'accepts users' do
      expect(subject.with_last_user(user)).to eql LsHash.new(last_user_id: user.sf_guard_user_id)
    end

    it 'accepts sf guard users' do
      expect(subject.with_last_user(user.sf_guard_user))
        .to eql LsHash.new(last_user_id: user.sf_guard_user_id)
    end

    it 'raises error if provided invalid class type' do
      expect { subject.with_last_user([]) }.to raise_error(TypeError)
    end
  end

  describe 'remove_nil_vals' do
    specify do
      expect(LsHash.new('one' => 1, 'two' => nil).remove_nil_vals)
        .to eql LsHash.new('one' => 1)
    end

    specify do
      expect(LsHash.new('one' => 1, 'two' => 2).remove_nil_vals)
        .to eql LsHash.new('one' => 1, 'two' => 2)
    end
  end
end
