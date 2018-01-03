require 'rails_helper'

describe DeletionRequest, type: :model do
  let(:deletion_request) { create(:deletion_request) }

  describe "inheritance" do
    it "subclasses UserRequest" do
      expect(deletion_request).to be_a UserRequest
    end

    it "has class DeletionRequest" do
      expect(deletion_request).to be_a DeletionRequest
    end

    it "has type DeletionRequest" do
      expect(deletion_request.type).to eql "DeletionRequest"
    end
  end

  describe "validation" do
    it { should validate_presence_of(:entity_id) }
  end

  describe "associations" do
    it { should belong_to(:entity) }
  end

  it "defaults to status pending" do
    expect(deletion_request.status).to eql 'pending'
  end

  describe "methods" do
    let(:reviewer) { create(:admin_user) }

    describe "#approve!" do
      before do
        allow(deletion_request.entity).to receive(:soft_delete)
        deletion_request.approve! # implicitly tests that #approve! is implemented
      end

      it "executes the requested merge" do
        expect(deletion_request.entity).to have_received(:soft_delete)
      end
    end
  end
end
