require 'rails_helper'

describe MergeRequest, type: :model do

  let(:merge_request) { create(:merge_request) }

  describe "inheritance" do
    it "subclasses UserRequest" do
      expect(merge_request).to be_a UserRequest
    end
    it "has type MergeRequest" do
      expect(merge_request.type).to eql UserRequest::TYPES[:merge]
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

  it "defaults to status pending" do
    expect(merge_request.status).to eql 'pending'
  end


  it "implements #approve" do
    expect{ merge_request.approve }.not_to raise_error
  end

  describe "#approve" do

    before { allow(merge_request.source).to receive(:merge_with) }
    
    it "executes the requested merge" do
      merge_request.approve
      expect(merge_request.source).to have_received(:merge_with).with(merge_request.dest)
    end

    it "records the approval" do
      expect { merge_request.approve }.to change(merge_request, :status).to('approved')
    end
  end
end
