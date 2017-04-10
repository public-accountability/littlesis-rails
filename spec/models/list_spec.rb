require 'rails_helper'

describe List do
  before(:all)  { DatabaseCleaner.start }
  after(:all) { DatabaseCleaner.clean }

  it { should belong_to(:user) }

  it 'validates name' do
    l = List.new
    expect(l).not_to be_valid
    l.name = "bad politicians"
    expect(l).to be_valid
  end

  context "active relationships" do
    it 'joins entities via ListEntity' do
      list_entity_count = ListEntity.count
      list = create(:list)
      inc = create(:mega_corp_inc)
      llc = create(:mega_corp_llc)
      # Every time you create an entity you create a ListEntity because all entites
      # are in a network and all networks are lists joined via the list_entities table.
      # This is why there are 2 list_entities to start with.
      expect(ListEntity.count).to eql (list_entity_count + 2)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: llc.id)
      expect(ListEntity.count).to eql (list_entity_count + 4)
      expect(list.list_entities.count).to eql 2
    end

    it 'has images through entities' do
      list = create(:list)
      inc = create(:mega_corp_inc)
      create(:image, entity_id: inc.id)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      expect(list.images.count).to eq (1)
      expect(list.images.first.filename).to eql ('image.jpg')
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

    it 'has notes & notelists' do
      list = create(:list)
      note = create(:note)
      expect(list.note_lists.count).to eq(0)
      NoteList.create(list_id: list.id, note_id: note.id)
      expect(list.note_lists.count).to eq(1)
      expect(list.notes.count).to eq(1)
    end

    # it 'has note networks and network_notes'
    # it 'has users through default_network'
    # it 'has sf_guard_group_lists'
    # it 'has topic_lists & topics'
    # it 'has one default topic'
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
      l = build(:list, is_private: false)
      expect(l.user_can_access?).to be true
    end

    it 'returns true if user is provided and is a public list' do
      l = build(:list, is_private: false)
      expect(l.user_can_access?(build(:user))).to be true
      expect(l.user_can_access?(123)).to be true
    end

    it 'returns false for private lists' do
      l = build(:list, is_private: true, creator_user_id: rand(1000))
      expect(l.user_can_access?).to be false
      expect(l.user_can_access?(build(:user))).to be false
    end

    it 'returns true for private lists if user is owner of the list' do
      user = build(:user_with_id)
      user2 = build(:user, id: (user.id + 1))
      l = build(:list, is_private: true, creator_user_id: user.id)
      expect(l.user_can_access?(user)).to be true
      expect(l.user_can_access?(user.id)).to be true
      expect(l.user_can_access?(user2)).to be false
      expect(l.user_can_access?(user2.id)).to be false
      expect(l.user_can_access?).to be false
    end
  end

  context 'Using paper_trail for versioning' do
    with_versioning do
      it 'records created, modified, and deleted versions' do 
        l = create(:list)
        expect(l.versions.size).to eq(1)
        l.name = "change the name name!"
        l.save
        expect(l.versions.size).to eq(2)
        expect(l.versions.last.event).to eq('update')
        l.destroy
        expect(l.versions.size).to eq(3)
        # this is 'update' and not destroy because the implementation of soft delete
        expect(l.versions.last.event).to eq('update')
      end
    end
  end
end
