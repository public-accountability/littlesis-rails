require 'rails_helper'

describe UserRequest, type: :model do

  let(:user_request){ create(:user_request) }

  describe "schema" do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:type).of_type(:string) }
    it { should have_db_column(:status).of_type(:integer) }
    it { should have_db_column(:source_id).of_type(:integer) }
    it { should have_db_column(:dest_id).of_type(:integer) }
  end

  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:type) }

    it { should define_enum_for(:status).with %i[pending approved denied] }
    it { should validate_inclusion_of(:type).in_array %w[MergeRequest] }

    it { should_not validate_presence_of(:source_id) }
    it { should_not validate_presence_of(:dest_id) }
  end

  describe "status" do

    it "defaults to pending" do
      expect(user_request.pending?).to be true
      expect(user_request.status).to eql 'pending'
    end

    it "can be set to approved" do
      user_request.approved!
      expect(user_request.approved?).to be true
      expect(user_request.status).to eql 'approved'
    end

    it "can be set to denied" do
      user_request.denied!
      expect(user_request.denied?).to be true
      expect(user_request.status).to eql 'denied'
    end
  end

  describe "abstract methods" do
    it "defines an abstract #approve method" do
      expect { user_request.approve }.to raise_error NotImplementedError
    end
  end
end
