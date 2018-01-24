require 'rails_helper'

describe LsHash do
  subject { LsHash.new }

  it { is_expected.to be_a ActiveSupport::HashWithIndifferentAccess }
  it { is_expected.to respond_to :with_last_user }

  specify do
    expect(subject.with_last_user(123)).to eql LsHash.new(last_user_id: 123)
    expect(subject.with_last_user('123')).to eql LsHash.new(last_user_id: 123)
  end
end
