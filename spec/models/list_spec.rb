require 'rails_helper'

describe List do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:list_entities) }
  it { is_expected.to have_many(:entities) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:short_description).is_at_most(255) }

  it { is_expected.to have_db_column(:access) }
  it { is_expected.not_to have_db_column(:is_network) }

  context 'active relationship' do
    it 'joins entities via ListEntity' do
      list = create(:list)
      inc = create(:mega_corp_inc)
      llc = create(:mega_corp_llc)
      expect(ListEntity.count).to eql 0
      ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: llc.id)
      expect(ListEntity.count).to eql 2
      expect(list.list_entities.count).to eql 2
    end

    it 'has images through entities' do
      list = create(:list)
      inc = create(:mega_corp_inc)
      create(:image, entity_id: inc.id)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      expect(list.images.count).to eq 1
    end

    it 'has groups' do
      list = create(:list)
      grp = create(:group)
      expect(list.groups.count).to eq (0)
      GroupList.create(list_id: list.id, group_id: grp.id)
      expect(list.groups.count).to eq(1)
      expect(GroupList.count).to eq(1) 
      expect(grp.lists.first).to eq(list)
      expect(list.groups.first).to eq(grp)
    end
  end

  context 'methods' do
    it 'name_to_legacy_slug' do
      l = build(:list, name: 'my/cool+name')
      expect(l.name_to_legacy_slug).to eq("my~cool_name")
    end
    it 'leagacy_url' do
      list = build(:list, id: 8)
      expect(list.legacy_url).to eq("/list/8/Fortune_1000_Companies")
      expect(list.legacy_url('bam')).to eq("/list/8/Fortune_1000_Companies/bam")
    end
  end

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
      l = build(:open_list)
      expect(l.user_can_access?(build(:user))).to be true
      expect(l.user_can_access?(123)).to be true
    end

    it 'returns false for private lists' do
      l = build(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: 9999)
      expect(l.user_can_access?).to be false
      expect(l.user_can_access?(create_basic_user)).to be false
    end

    it 'returns true for private lists if user is owner of the list' do
      user = create_basic_user
      user2 = create_basic_user
      expect(user).to receive(:permissions)
                       .and_return(double(:list_permissions => {:viewable => true}))

      expect(user2).to receive(:permissions)
                       .and_return(double(:list_permissions => {:viewable => false}))
      l = build(:list, access: Permissions::ACCESS_PRIVATE, creator_user_id: user.id)

      expect(l.user_can_access?(user)).to be true
      expect(l.user_can_access?(user.id)).to be true
      expect(l.user_can_access?(user2)).to be false
      expect(l.user_can_access?(user2.id)).to be false
      expect(l.user_can_access?).to be false
    end
  end

  describe 'restricted?' do
    # it 'restricts access to network lists' do
    #   l = build(:list, is_network: true)
    #   expect(l.restricted?).to be true
    # end
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
end
