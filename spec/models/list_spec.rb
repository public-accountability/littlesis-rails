describe List do
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to have_many(:list_entities) }
  it { is_expected.to have_many(:entities) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:short_description).is_at_most(255) }

  it { is_expected.to have_db_column(:access) }
  it { is_expected.not_to have_db_column(:is_network) }

  context 'SoftDelete' do
    it 'removes item from the count but not he unscoped count' do
      l = create(:list)
      expect(List.count).to eq(List.unscoped.count)
      l.destroy
      expect(List.count).not_to eq(List.unscoped.count)
    end

    it 'sets is_deleted to true' do
      l = create(:list)
      expect(l.is_deleted).to eq(false)
      l.destroy
      expect(l.is_deleted).to eq(true)
    end

    it 'List.all returns lists that are not deleted and List.unscoped.deleted returns the deleted lists' do
      c = List.count
      list1 = create(:list, name: 'list1')
      list2 = create(:list, name: 'list2')
      expect(List.all.count).to eq(c + 2)
      expect(List.unscoped.all.count).to eq(c + 2)
      expect(List.unscoped.active.all.count).to eq(c + 2)
      expect(List.unscoped.deleted.all.count).to eq(0)
      list1.destroy
      expect(List.all.count).to eq(c + 1)
      expect(List.unscoped.all.count).to eq(c + 2)
      expect(List.active.all.count).to eq(c + 1)
      expect(List.unscoped.deleted.all.count).to eq(1)
      list2.destroy
      expect(List.all.count).to eq(c)
      expect(List.unscoped.all.count).to eq(c + 2)
      expect(List.unscoped.active.all.count).to eq(c)
      expect(List.unscoped.deleted.all.count).to eq(2)
    end
  end

  describe '#user_can_access?' do
    it 'returns true if no user is provided and is a public list' do
      l = build(:open_list)
      expect(l.user_can_access?).to be true
    end

    it 'returns true if user is provided and is a public list' do
      expect(build(:open_list).user_can_access?(build(:user_with_id))).to be true
    end

    it 'returns false for private lists' do
      l = build(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: 9999)
      expect(l.user_can_access?).to be false
      expect(l.user_can_access?(build(:user))).to be false
    end

    it 'returns true for private lists if user is owner of the list' do
      user = create_basic_user
      user2 = create_basic_user
      l = build(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: user.id)

      expect(l.user_can_access?(user)).to be true
      expect(l.user_can_access?(user.id)).to be true
      expect(l.user_can_access?(user2)).to be false
      expect(l.user_can_access?(user2.id)).to be false
      expect(l.user_can_access?).to be false
    end
  end

  describe '#user_can_edit?' do
    let(:list_owner) { create_editor }
    let(:other_person) { create_editor }
    let(:permitted_lister) { create_collaborator }
    let(:private_list) { create(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: list_owner.id) }
    let(:public_list) { create(:list, access: Permissions::ACCESS_OPEN) }
    let(:closed_list) { create(:list, access: Permissions::ACCESS_CLOSED, creator_user_id: list_owner.id) }

    it 'returns true for private lists only if user is owner of the list' do
      expect(private_list.user_can_edit?(list_owner)).to be true
      expect(private_list.user_can_edit?(other_person)).to be false
      expect(private_list.user_can_edit?(nil)).to be false
    end

    it 'returns true for closed lists only if user is owner of the list' do
      expect(closed_list.user_can_edit?(list_owner)).to be true
      expect(closed_list.user_can_edit?(other_person)).to be false
      expect(closed_list.user_can_edit?(nil)).to be false
    end

    it 'returns true for public lists only if the user has list permissions' do
      expect(public_list.user_can_edit?(permitted_lister)).to be true
      expect(public_list.user_can_edit?(other_person)).to be false
      expect(public_list.user_can_edit?(nil)).to be false
    end
  end

  describe '.viewable' do
    let(:list_owner) { create_editor }
    let!(:other_person) { create_editor }
    let!(:private_list) { create(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: list_owner.id) }
    let!(:public_list) { create(:list, access: Permissions::ACCESS_OPEN) }
    let!(:closed_list) { create(:list, access: Permissions::ACCESS_CLOSED, creator_user_id: list_owner.id) }

    it "returns correct viewable lists" do
      expect(List.viewable(list_owner)).to include(private_list, public_list, closed_list)
    end

    it "doesn't return non-viewable lists" do
      expect(List.viewable(other_person)).to include(public_list, closed_list)
      expect(List.viewable(other_person)).not_to include(private_list)
    end
  end

  describe '.editable' do
    let(:list_owner) { create_editor }
    let!(:other_person) { create_restricted_user }
    let!(:permitted_lister) { create_collaborator }
    let!(:private_list) { create(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: list_owner.id) }
    let!(:public_list) { create(:list, access: Permissions::ACCESS_OPEN) }
    let!(:closed_list) { create(:list, access: Permissions::ACCESS_CLOSED, creator_user_id: list_owner.id) }

    it "returns correct editable lists" do
      expect(List.editable(list_owner).to_a).to include(private_list, closed_list)
      expect(List.editable(permitted_lister).to_a).to include(public_list)
    end

    it "doesn't return non-editable lists" do
      expect(List.editable(other_person)).not_to include(private_list, public_list, closed_list)
      expect(List.editable(permitted_lister)).not_to include(private_list)
    end
  end

  describe 'restricted?' do
    it 'restricts access to admin lists' do
      expect(build(:list, is_admin: true).restricted?).to be true
    end
  end

  context 'Using paper_trail for versioning' do
    with_versioning do
      it 'records created, modified, and deleted versions' do
        l = create(:list)
        expect(l.versions.size).to eq 1
        l.name = "change the name name!"
        l.save
        expect(l.versions.size).to eq 2
        expect(l.versions.last.event).to eq 'update'
        l.destroy
        expect(l.versions.size).to eq 3
        expect(l.versions.last.event).to eq 'soft_delete'
      end
    end
  end

  describe 'ordering' do
    let!(:org) { create(:entity_org) }
    let!(:three_list) { create(:list).tap { |l| 3.times { ListEntity.create(list_id: l.id, entity_id: org.id) } } }
    let!(:two_list) { create(:list).tap { |l| 2.times { ListEntity.create(list_id: l.id, entity_id: org.id) } } }
    let!(:one_list) { create(:list).tap { |l| 1.times { ListEntity.create(list_id: l.id, entity_id: org.id) } } }
    let!(:none_list) { create(:list) }

    it 'ranks by number of entities' do
      lists = List.all
      expect(lists.order_by_entity_count.to_a).to match([three_list, two_list, one_list, none_list])
    end
  end
end
