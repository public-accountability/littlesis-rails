require 'rails_helper'

describe MergeRequest, type: :model do

  subject { create(:merge_request) }

  describe "inheritance" do
    it "subclasses UserRequest" do
      expect(subject).to be_a UserRequest
    end
    it "has type MergeRequest" do
      expect(subject.type).to eql UserRequest::TYPES[:merge]
    end
  end

  describe "validation" do
    it { should validate_presence_of(:source_id) }
    it { should validate_presence_of(:dest_id) }
  end

  describe "associations" do
    it { should belong_to(:source)
               .class_name("Entity")
               .with_foreign_key("source_id") }

    it { should belong_to(:dest)
                  .class_name("Entity")
                  .with_foreign_key("dest_id") }
  end

  describe "status" do
    it "defaults to pending" do
      expect(subject.status).to eql 'pending'
    end
  end
end
