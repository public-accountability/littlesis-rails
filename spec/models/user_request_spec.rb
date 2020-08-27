describe UserRequest, type: :model do
  let(:user_request) { create(:user_request) }

  describe "schema" do
    it { is_expected.to have_db_column(:user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:reviewer_id).of_type(:integer) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:integer) }
    it { is_expected.to have_db_column(:source_id).of_type(:integer) }
    it { is_expected.to have_db_column(:dest_id).of_type(:integer) }
    it { is_expected.to have_db_column(:justification).of_type(:text) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reviewer).class_name("User").with_foreign_key("reviewer_id").optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:justification) }

    it { is_expected.to define_enum_for(:status).with_values %i[pending approved denied] }
    it { is_expected.to validate_inclusion_of(:type).in_array %w[MergeRequest DeletionRequest ImageDeletionRequest ListDeletionRequest] }

    it { is_expected.not_to validate_presence_of(:reviewer_id) }
    it { is_expected.not_to validate_presence_of(:source_id) }
    it { is_expected.not_to validate_presence_of(:dest_id) }
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
    it "defines an abstract #approve! method" do
      expect { user_request.approve! }.to raise_error NotImplementedError
    end
  end

  describe "concrete methods" do
    let(:reviewer) { create(:admin_user) }

    describe "#description" do
      context "with a MergeRequest" do
        it "returns 'merge'" do
          expect(user_request.description).to eql 'merge'
        end
      end

      context "with a DeletionRequest" do
        let(:user_request) { create(:user_request, type: 'DeletionRequest') }

        it "returns 'deletion" do
          expect(user_request.description).to eql 'deletion'
        end
      end
    end

    describe "#approved_by!" do
      before do
        allow(user_request).to receive(:approve!).and_return(nil)
        user_request.approved_by!(reviewer)
      end

      it "calls approve!" do
        expect(user_request).to have_received(:approve!)
      end

      it "records the approval" do
        expect(user_request.status).to eql('approved')
      end

      it "records the reviewer" do
        expect(user_request.reviewer).to eql(reviewer)
      end
    end

    describe "#denied_by!" do
      before { user_request.denied_by!(reviewer) }

      it "records the denial" do
        expect(user_request.status).to eql 'denied'
      end

      it "records the reviewer" do
        expect(user_request.reviewer).to eql reviewer
      end
    end
  end
end
