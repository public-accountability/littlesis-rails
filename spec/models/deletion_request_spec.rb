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
    it { is_expected.to validate_presence_of(:entity_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:entity) }
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

  describe "DeletionRequest.cleanup" do
    let(:user) { create_basic_user }
    let(:entity) { create(:entity_person) }

    # let(:merged_entity) { create(:entity_person, merged_id: create(:entity_person).id) }
    let(:merged_entity) { create(:entity_person, merged_id: entity.id) }

    let(:deleted_entity) do
      create(:entity_person).tap(&:soft_delete)
    end

    def create_deletion_request(e)
      DeletionRequest.create!(
        justification: Faker::Lorem.sentence,
        user: User.system_user,
        entity_id: e.id
      )
    end

    specify do
      deletion_requests = [create_deletion_request(entity),
                           create_deletion_request(merged_entity),
                           create_deletion_request(deleted_entity)]

      deletion_requests.each do |dr|
        expect(dr.status).to eq 'pending'
      end

      DeletionRequest.cleanup

      deletion_requests.each(&:reload)

      expect(deletion_requests[0].status).to eq 'pending'
      expect(deletion_requests[1].status).to eq 'denied'
      expect(deletion_requests[2].status).to eq 'denied'

    end
  end
end
