# rubocop:disable RSpec/MultipleMemoizedHelpers

describe EntityMerger, :merging_helper do
  subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

  let(:source_org) { create(:entity_org, :with_org_name) }
  let(:dest_org) { create(:entity_org, :with_org_name) }
  let(:source_person) { create(:entity_person, :with_person_name) }
  let(:dest_person) { create(:entity_person, :with_person_name) }

  describe 'initializing' do
    let(:source) { build(:org) }
    let(:dest) { build(:org) }

    it 'requires both source and dest entities' do
      expect { EntityMerger.new(source: source) }.to raise_error(ArgumentError)
      expect { EntityMerger.new(dest: dest) }.to raise_error(ArgumentError)
      expect { EntityMerger.new }.to raise_error(ArgumentError)
      expect { EntityMerger.new(source: source, dest: build(:document)) }.to raise_error(ArgumentError)
    end

    it 'sets source and dest attributes' do
      em = EntityMerger.new(source: source, dest: dest)
      expect(em.source).to eql source
      expect(em.dest).to eql dest
    end
  end

  it 'can only merge entities that have the same primary extension' do
    expect { EntityMerger.new source: build(:person), dest: build(:org) }.to raise_error(EntityMerger::ExtensionMismatchError)
  end

  it 'sets the "merged_id" fields of the merged entity to be the id of the merged entity' do
    expect { merger.merge! }.to change { Entity.unscoped.find(source_org.id).merged_id }.from(nil).to(dest_org.id)
  end

  it 'marks the merged entity as deleted' do
    expect { merger.merge! }.to change { Entity.unscoped.find(source_org.id).is_deleted }.from(false).to(true)
  end

  describe 'extensions' do
    subject(:merger) { EntityMerger.new(source: source_person, dest: dest_person) }

    context 'with no new extensions on the source' do
      it 'extensions contains non-new extension' do # rubocop:disable RSpec/ExampleLength
        merger.merge_extensions
        expect(merger.extensions.length).to eq 1
        extension = merger.extensions.first
        expect(extension).to be_a EntityMerger::Extension
        expect(extension.new).to be false
        expect(extension.ext_id).to eq 1
        expect(extension.fields).to eq source_person.person.attributes.except('id', 'entity_id')
      end
    end

    context 'when the source has a new extension with fields' do
      before do
        source_person.add_extension('PoliticalCandidate') # ext_id = 3
        source_person.person.update(name_middle: 'MIDDLE')
        merger.merge_extensions
      end

      it 'has 2 extensions' do
        expect(merger.extensions.length).to eq 2
      end

      it 'has new extension' do
        new_ext = merger.extensions.find { |e| e.new == true }
        expect(new_ext.new).to be true
        expect(new_ext.ext_id).to eq 3
        expect(new_ext.fields.keys).to contain_exactly('is_federal', 'is_state', 'is_local', 'pres_fec_id', 'senate_fec_id', 'house_fec_id', 'crp_id')
      end

      describe 'merge!' do
        reset_merger
        it 'adds new extenion to destination' do
          expect { merger.merge! }
            .to change { Entity.find(dest_person.id).extension_names }.from(['Person']).to(%w[Person PoliticalCandidate])
        end

        it 'updates attributes of existing extensions' do
          expect { merger.merge! }
            .to change { Entity.find(dest_person.id).person.name_middle }
                  .from(nil).to('MIDDLE')
        end

        it 'doest not update non-nil attributes of existing extensions' do
          expect { merger.merge! }
            .not_to change { Entity.find(dest_person.id).person.name_first }
        end
      end
    end

    context 'when the source has a new extension without fields' do
      subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

      before do
        source_org.add_extension('Philanthropy') # ext_id = 9
        merger.merge_extensions
      end

      it { expect(merger.extensions.length).to eq 2 }

      it 'contains new philanthroy extension' do
        new_ext = merger.extensions.find { |e| e.new == true }
        expect(new_ext.ext_id).to eq 9
        expect(new_ext.fields).to eq({})
      end

      describe 'merge!' do
        reset_merger
        it 'adds new extension to the destination' do
          expect { merger.merge! }
            .to change { Entity.find(dest_org.id).has_extension?('Philanthropy') }.from(false).to(true)
        end
      end
    end
  end

  describe 'contact info' do
    subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

    describe 'addresses' do
      let!(:address) { create(:legacy_address, entity_id: source_org.id) }

      context 'when source has a new address' do
        before { merger.merge_contact_info }

        it 'duplicates address and appends to @contact_info' do
          verify_contact_info_length_type_and_entity_id(LegacyAddress, dest_org.id)
        end
      end

      context 'when source and dest have same address' do
        before do
          allow(dest_org).to receive(:addresses).with(:present?).and_return(true)
          allow(dest_org).to receive(:addresses).and_return([address.dup])
        end

        it 'skipped already existing address' do
          merger.merge_contact_info
          expect(merger.contact_info.length).to be_zero
        end
      end
    end

    describe 'email' do
      let!(:email) { create(:email, entity_id: source_org.id) }

      context 'when source has an new email' do
        before { merger.merge_contact_info }

        it 'duplicates email and appends to @contact_info' do
          verify_contact_info_length_type_and_entity_id(Email, dest_org.id)
        end
      end

      context 'when dest has same email address' do
        before do
          create(:email, address: email.address, entity_id: dest_org.id)
          merger.merge_contact_info
        end

        specify { expect(merger.contact_info.length).to be_zero }
      end
    end

    describe 'phone' do
      let!(:phone) { create(:phone, entity_id: source_org.id) }

      context 'when source has an new phone' do
        before { merger.merge_contact_info }

        it 'duplicates phone and appends to @contact_info' do
          verify_contact_info_length_type_and_entity_id(Phone, dest_org.id)
        end
      end

      context 'when dest has phone with same number' do
        before do
          create(:phone, number: phone.number, entity_id: dest_org.id)
          merger.merge_contact_info
        end

        specify { expect(merger.contact_info.length).to be_zero }
      end
    end

    describe 'source has one phone, email, addresses to be transfered' do
      before do
        create(:phone, entity_id: source_org.id)
        create(:email, entity_id: source_org.id)
        create(:legacy_address, entity_id: source_org.id)
      end

      it 'adds addresses to the destination entity' do
        expect { merger.merge! }
          .to change { dest_org.reload.addresses.count }.by(1)
      end

      it 'adds emails to the destination entity' do
        expect { merger.merge! }
          .to change { dest_org.reload.emails.count }.by(1)
      end

      it 'adds phone numbers to the destination entity' do
        expect { merger.merge! }
          .to change { dest_org.reload.phones.count }.by(1)
      end

      it 'removes email, phone, and addresses from source' do
        merger.merge!
        expect(Phone.where(entity_id: source_org.id).exists?).to be false
        expect(LegacyAddress.where(entity_id: source_org.id).exists?).to be false
        expect(Email.where(entity_id: source_org.id).exists?).to be false
      end
    end
  end

  describe 'lists' do
    subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

    let(:list1) { create(:list) }
    let(:list2) { create(:open_list) }
    let(:list3) { create(:closed_list) }

    it '@lists is empty by default' do
      expect(merger.lists).to eql []
      merger.merge_lists
      expect(merger.lists).to eql Set.new
    end

    context 'when source is on two lists that the destination is not on' do
      before do
        ListEntity.create!(list_id: list1.id, entity_id: source_org.id)
        ListEntity.create!(list_id: list2.id, entity_id: source_org.id)
        ListEntity.create!(list_id: list3.id, entity_id: dest_org.id)
        merger.merge_lists
      end

      it '@lists contains a set of new list_ids' do
        expect(merger.lists).to eql([list1.id, list2.id].to_set)
      end

      describe 'merge!' do
        reset_merger
        it 'adds destintion entity to new lists' do
          expect { merger.merge! }
            .to change { dest_org.reload.lists.count }.from(1).to(3)
        end
      end
    end

    context 'when source and dest are on the same list' do
      before do
        ListEntity.create!(list_id: list1.id, entity_id: source_org.id)
        ListEntity.create!(list_id: list1.id, entity_id: dest_org.id)
        merger.merge_lists
      end

      specify { expect(merger.lists).to be_empty }

      describe 'merge!' do
        reset_merger

        specify do
          expect { merger.merge! }.not_to change { dest_org.reload.lists.count }
        end

        specify do
          expect { merger.merge! }.to change(ListEntity, :count).by(-1)
        end

      end
    end

    context 'when source is on a deleted list' do
      before do
        ListEntity.create!(list_id: list1.id, entity_id: source_org.id)
        list1.soft_delete
      end

      describe 'merge!' do
        reset_merger

        it 'adds destination entity to new list' do
          expect(list1.is_deleted).to be true
          merger.merge!
          expect(list1.reload.entities.first.id).to eq dest_org.id
        end
      end
    end
  end

  describe 'images' do
    subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

    let(:image) { create(:image, entity_id: source_org.id) }

    before do
      image
      merger.merge_images
    end

    it 'changes images entity id' do
      expect(merger.images.length).to eq 1
      expect(merger.images.first).to be_a Image
      expect(merger.images.first.entity_id).to eql dest_org.id
    end

    describe 'merge!' do
      reset_merger

      it 'transfers images to new entity' do
        expect(Image.find(image.id).entity_id).to eql source_org.id
        merger.merge!
        expect(Image.find(image.id).entity_id).to eql dest_org.id
      end
    end
  end

  describe 'aliases' do
    context 'when there are no new aliases' do
      before do
        dest_org.aliases.create!(name: source_org.name)
        merger.merge_aliases
      end

      specify { expect(merger.aliases).to eq [] }
    end

    context 'when source has 1 new aliases' do
      let(:corp_name) { Faker::Company.unique.name }

      before do
        dest_org.aliases.create!(name: source_org.name)
        source_org.aliases.create!(name: corp_name)
        merger.merge_aliases
      end

      it 'adds new aliases to @aliases' do
        expect(merger.aliases.length).to eq 1
        expect(merger.aliases.first).to be_a Alias
        expect(merger.aliases.first.name).to eq corp_name
        expect(merger.aliases.first.entity_id).to eq dest_org.id
        expect(merger.aliases.first.persisted?).to be false
      end

      describe 'merge!' do
        reset_merger
        it 'creates new aliases on destination entity' do
          expect { merger.merge! }.to change { Entity.find(dest_org.id).aliases.count }.by(1)
          expect(Alias.last.attributes.slice('name', 'entity_id'))
            .to eql('name' => corp_name, 'entity_id' => dest_org.id)
        end
      end
    end
  end

  describe 'locations' do
    let(:entity_merger) { EntityMerger.new(source: source_person, dest: dest_person) }

    before do
      source_person.locations.create!(region: 'Latin America and Caribbean')
    end

    it 'transfers locations' do
      expect { entity_merger.merge! }.to change { dest_person.locations.count }.from(0).to(1)
    end
  end

  describe 'references/documents' do
    subject(:merger) { EntityMerger.new(source: source_person, dest: dest_person) }

    let(:document) { create(:document) }

    context 'when there are no new documents' do
      before do
        source_person.add_reference(url: document.url)
        dest_person.add_reference(url: document.url)
        dest_person.add_reference(url: Faker::Internet.url)
        merger.merge_references
      end

      it 'does not add new documents ids' do
        expect(merger.document_ids).to be_empty
      end

      describe 'merge!' do
        reset_merger
        specify do
          expect { merger.merge! }.not_to change { dest_person.references.count }
        end
      end
    end

    context 'with a new document' do
      before do
        source_person.add_reference(url: document.url)
        merger.merge_references
      end

      it 'adds one new documents ids' do
        expect(merger.document_ids.length).to eq 1
        expect(merger.document_ids.first).to eq document.id
      end

      describe 'merge!' do
        reset_merger

        it 'creates a new reference for the destination entity' do
          expect { merger.merge! }.to change { Entity.find(dest_person.id).references.count }.by(1)
          expect(dest_person.references.last.document_id).to eql document.id
        end
      end
    end
  end

  describe 'tags' do
    let(:tags) { Array.new(2) { create(:tag) } }

    context 'when source and dest have the same tag' do
      before do
        source_org.add_tag(tags.first.id)
        dest_org.add_tag(tags.first.id)
        merger.merge_tags
      end

      specify { expect(merger.tag_ids).to eq Set.new }
    end

    context 'when source and dest have different tags' do
      before do
        source_org.add_tag(tags.second.id)
        dest_org.add_tag(tags.first.id)
        merger.merge_tags
      end

      it 'adds tag to list of tag ids' do
        expect(merger.tag_ids).to eql Set.new([tags.second.id])
      end

      describe 'merge!' do
        reset_merger
        it 'adds the new tag to the destination entity' do
          expect { merger.merge! }
            .to change { dest_org.tags.include?(tags.second) }.from(false).to(true)
        end
      end
    end
  end

  describe 'articles' do
    subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

    let(:article) { create(:article) }

    context 'when source has no articles' do
      before { merger.merge_articles }

      specify { expect(merger.articles).to eql [] }
    end

    context 'when source has article not on destination' do
      before do
        ArticleEntity.create!(article_id: article.id, entity_id: source_org.id)
        merger.merge_articles
      end

      it 'changes article entity id' do
        expect(merger.articles.length).to eq 1
        expect(merger.articles.first).to be_a ArticleEntity
        expect(merger.articles.first.entity_id).to eql dest_org.id
        expect(merger.articles.first.article_id).to eql article.id
      end

      describe 'merge!' do
        reset_merger

        it 'transfers the ArticleEntity' do
          expect { merger.merge! }.to change { dest_org.article_entities.count }.from(0).to(1)
        end

        it 'does not create new ArticleEntities' do
          expect { merger.merge! }.not_to change(ArticleEntity, :count)
        end
      end
    end

    context 'when both source and destination entities have the same article' do
      before do
        ArticleEntity.create!(article_id: article.id, entity_id: source_org.id)
        ArticleEntity.create!(article_id: article.id, entity_id: dest_org.id)
        merger.merge_articles
      end

      it 'sets @articles to be an empty array' do
        expect(merger.articles.length).to be 0
        expect(merger.articles).to eql []
      end

      describe 'merge!' do
        reset_merger

        it 'does not transfer the ArticleEntity' do
          expect { merger.merge! }.not_to change { dest_org.reload.article_entities.count }
        end
      end
    end
  end

  describe 'Os Entity Category' do
    subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

    let(:os_category) { build(:os_category_private_equity) }

    context 'with a new category id' do
      before do
        OsEntityCategory.create!(category_id: os_category.category_id, entity_id: source_org.id, source: 'OpenSecrets')
        merger.merge_os_categories
      end

      it 'changes os_entity_category entity id' do
        expect(merger.os_categories.length).to be 1
        expect(merger.os_categories.first).to be_a OsEntityCategory
        expect(merger.os_categories.first.entity_id).to eql dest_org.id
      end

      describe 'merge!' do
        reset_merger

        it 'transfers the OsEntityCategory' do
          expect { merger.merge! }.to change { dest_org.os_entity_categories.count }.from(0).to(1)
        end

        it 'does not create new OsEntitycategory' do
          expect { merger.merge! }.not_to change(OsEntityCategory, :count)
        end
      end
    end

    context 'when there are no new category ids' do
      before do
        OsEntityCategory.create!(category_id: os_category.category_id, entity_id: source_org.id, source: 'OpenSecrets')
        OsEntityCategory.create!(category_id: os_category.category_id, entity_id: dest_org.id, source: 'OpenSecrets')
        merger.merge_os_categories
      end

      it '@os_categories is empty' do
        expect(merger.os_categories).to be_empty
      end
    end
  end

  describe 'merging child entities' do
    let!(:child_entities) { Array.new(2) { create(:entity_org, parent_id: source_org.id) } }

    it 'adds child entities to @child_entities' do
      expect(merger.child_entities.length).to be_zero
      merger.merge_child_entities
      expect(merger.child_entities.length).to eq 2
      expect(merger.child_entities.first).to be_a EntityMerger::ChildEntity
    end

    it 'changes parent org' do
      merger.merge!
      child_entities.each do |e|
        expect(Entity.find(e.id).parent_id).to eql dest_org.id
      end
    end
  end

  describe 'merging party members' do
    let!(:party_members) do
      Array.new(2) do
        create(:entity_person).tap { |e| e.person.update!(party_id: source_org.id) }
      end
    end

    it 'adds party members to @party_members' do
      expect(merger.party_members.length).to be_zero
      merger.merge_party_members
      expect(merger.party_members.length).to eq 2
      expect(merger.party_members.first).to be_a EntityMerger::PartyMember
    end

    it 'changes party id' do
      merger.merge!
      party_members.each do |e|
        expect(Entity.find(e.id).person.party_id).to eql dest_org.id
      end
    end
  end

  describe 'merging relationships' do
    let(:other_org) { create(:entity_org, :with_org_name) }

    context 'when source has 2 relationships' do
      let(:donation_relationship) { create(:donation_relationship, entity: source_org, related: other_org) }
      let(:generic_relationship) { create(:generic_relationship, entity: other_org, related: source_org) }

      before do
        donation_relationship
        generic_relationship
        merger.merge_relationships
      end

      it 'populates @relationships with unsaved new relationships' do
        expect(merger.relationships.length).to eq 2
        expect(merger.relationships.first).to be_a EntityMerger::MergedRelationship
        expect(merger.potential_duplicate_relationships).to be_empty
      end

      it 'changes entity ids' do
        donation, generic = merger.relationships.sort_by { |r| r.relationship.category_id }.map(&:relationship)
        expect(donation).to have_attributes(entity1_id: dest_org.id, entity2_id: other_org.id, category_id: 5, persisted?: false)
        expect(generic).to have_attributes(entity1_id: other_org.id, entity2_id: dest_org.id, persisted?: false)
      end

      describe '#merge!' do
        reset_merger

        it 'creates 2 new relationships' do
          expect { merger.merge! }.to change { dest_org.reload.relationships.count }.by(2)
        end
      end
    end

    context 'when source has 2 relationships, one is a os match relationship' do
      before do
        create(:generic_relationship, entity: other_org, related: source_org)
        donation_relationship = create(:donation_relationship, entity: source_org, related: other_org)
        OsMatch.create!(os_donation_id: create(:os_donation).id, donor_id: source_org.id, relationship_id: donation_relationship.id)
        merger.merge_relationships
      end

      it 'skips os match relationships' do
        expect(source_org.relationships.count).to eq 2
        expect(merger.relationships.length).to eq 1
      end

      it 'adds os_match relationship to os_match_relationships' do
        expect(merger.os_match_relationships.length).to eq 1
      end

      describe 'merge!' do
        reset_merger

        it 'creates 1 new relationships' do
          expect { merger.merge! }.to change { dest_org.reload.relationships.count }.by(1)
        end
      end
    end

    context 'when source has 2 relationships, one is a ny match relationship' do
      subject(:merger) { EntityMerger.new(source: source_person, dest: dest_person) }

      let(:filer_id) { SecureRandom.hex(2) }
      let(:ny_filer) { create(:ny_filer, filer_id: filer_id) }
      let(:nys_politician) { create(:entity_person) }

      let(:ny_filer_entity) do
        NyFilerEntity.create!(filer_id: filer_id, entity_id: nys_politician.id, ny_filer: ny_filer)
      end

      let(:ny_disclosure) { create(:ny_disclosure, filer_id: filer_id) }

      before do
        ny_filer_entity
        create(:generic_relationship, entity: create(:entity_org), related: source_person)
        NyMatch.match(ny_disclosure.id, source_person.id)
        merger.merge_relationships
      end

      it 'skips os match relationships' do
        expect(source_person.relationships.count).to eq 2
        expect(merger.relationships.length).to eq 1
      end

      it 'adds ny_match relationship to ny_match_relationships' do
        expect(merger.ny_match_relationships.length).to eq 1
      end

      describe 'merge!' do
        reset_merger

        it 'creates 2 new relationships' do
          expect { merger.merge! }.to change { dest_person.reload.relationships.count }.by(2)
        end
      end
    end

    describe 'when source has 2 relationship, one is a duplicate' do
      before do
        create(:membership_relationship, entity: source_org, related: other_org)
        create(:membership_relationship, entity: dest_org, related: other_org)
        create(:generic_relationship, entity: other_org, related: source_org)
        merger.merge_relationships
      end

      it 'populates @relationships with unsaved new relationships' do
        expect(merger.relationships.length).to eq 2
      end

      it 'stores potential duplicate relationship' do
        expect(merger.potential_duplicate_relationships.length).to eq 1
        r = merger.potential_duplicate_relationships.first
        expect(r.triplet).to eql([dest_org.id, other_org.id, RelationshipCategory.name_to_id[:membership]])
      end
    end

    context 'when source has 1 relationship with 2 references' do
      let!(:documents) { Array.new(2) { create(:document) } }

      before do
        rel = create(:generic_relationship, entity: other_org, related: source_org)
        documents.each { |d| rel.references.find_or_create_by(document_id: d.id) }
        merger.merge!
      end

      it 'creates a new relationship and transfers references' do
        expect(Entity.find(dest_org.id).relationships.last.references.count).to eq 2
        expect(Entity.find(dest_org.id).relationships.map(&:documents).flatten.map(&:url).to_set).to eql documents.map(&:url).to_set
      end
    end
  end

  describe 'os donations' do
    subject(:merger) { EntityMerger.new(source: source_person, dest: dest_person) }

    let(:cmte_id) { Faker::Number.number(digits: 5).to_s }
    let(:recip_id) { Faker::Number.number(digits: 5).to_s }
    let(:os_committee) { create(:os_committee, cmte_id: cmte_id) }

    context 'when source has 2 os matches' do
      let(:os_donations) do
        [
          create(:os_donation, recipid: cmte_id, cmteid: cmte_id),
          create(:os_donation, recipid: cmte_id, cmteid: cmte_id, amount: 2)
        ]
      end

      before do
        allow(OsCommittee).to receive(:find_by).and_return(os_committee)
        os_donations.each { |osd| OsMatch.create!(os_donation_id: osd.id, donor_id: source_person.id) }
      end

      it 'removes os_matches from the source' do
        expect { merger.merge! }
          .to change { OsMatch.where(donor_id: source_person.id).count }.from(2).to(0)
      end

      it 'adds the os_matches from the destination' do
        expect { merger.merge! }
          .to change { OsMatch.where(donor_id: dest_person.id).count }.from(0).to(2)
      end

      it 'creates a new relationships for destination' do
        expect { merger.merge! }
          .to change { dest_person.reload.relationships.count }.by(1)
      end

      it 'removes the old donation relationship from the source' do
        expect { merger.merge! }
          .to change { source_person.reload.relationships.count }.by(-1)
      end
    end

    context 'when source is the recipient of two donations' do
      let(:donor) { create(:entity_person) }
      let(:os_donations) do
        [
          create(:os_donation, recipid: recip_id, cmteid: cmte_id),
          create(:os_donation, recipid: recip_id, cmteid: cmte_id, amount: 2)
        ]
      end
      let(:os_matches) { os_donations.map { |osd| OsMatch.create!(os_donation_id: osd.id, donor_id: donor.id) } }
      let(:relationship) { Relationship.find_by(entity1_id: donor.id, entity2_id: source_person.id) }

      before do
        source_person.add_extension('ElectedRepresentative', { crp_id: recip_id })
        allow(OsCommittee).to receive(:find_by).and_return(os_committee)
      end

      it 'updates the recipient id of the Os Matches' do
        expect(os_matches.first.recip_id).to eql source_person.id
        expect(os_matches.second.recip_id).to eql source_person.id
        merger.merge!
        expect(os_matches.first.reload.recip_id).to eql dest_person.id
        expect(os_matches.second.reload.recip_id).to eql dest_person.id
      end

      it 'updates the relationship' do
        relationship = os_matches.first.relationship
        expect(relationship.entity2_id).to eq(source_person.id)
        merger.merge!
        expect(relationship.reload.entity2_id).to eq(dest_person.id)
      end
    end

    context 'when source is an os committee' do
      subject(:merger) { EntityMerger.new(source: source_org, dest: dest_org) }

      let!(:donor) { create(:entity_person) }
      let!(:other_cmte_id) { Faker::Number.unique.number(digits: 5).to_s }

      let!(:recipient) do
        create(:entity_person).tap { |e| e.add_extension('ElectedRepresentative', { crp_id: recip_id }) }
      end

      let(:os_donations) do
        [create(:os_donation, recipid: recip_id, cmteid: cmte_id), create(:os_donation, recipid: recip_id, cmteid: cmte_id, amount: 2)]
      end

      let!(:random_match) do
        os_donation = create(:os_donation, recipid: recip_id, cmteid: other_cmte_id)
        OsMatch.create!(os_donation_id: os_donation.id, donor_id: donor.id)
      end

      let(:os_matches) { os_donations.map { |osd| OsMatch.create!(os_donation_id: osd.id, donor_id: donor.id) } }

      before do
        create(:entity_org).tap { |org| org.add_extension('PoliticalFundraising', { fec_id: other_cmte_id }) }
        source_org.add_extension('PoliticalFundraising', { fec_id: cmte_id })
      end

      it 'transfers PoliticalFundraising' do
        merger.merge!
        expect(dest_org.political_fundraising.fec_id).to eql cmte_id
      end

      it 'changes os_matches' do
        expect(os_matches).to all have_attributes(recip_id: recipient.id, cmte_id: source_org.id)

        merger.merge!

        os_matches.each do |m|
          expect(m.reload).to have_attributes(recip_id: recipient.id, cmte_id: dest_org.id)
        end
      end

      it 'does not change unrelated committees' do
        expect { merger.merge! }
          .not_to change { OsMatch.find(random_match.id).cmte_id }
      end
    end
  end

  describe 'cmp entities' do
    subject(:merger) { EntityMerger.new(source: source_person, dest: dest_person) }

    context 'when source person is a cmp entities' do
      let(:cmp_entity) do
        CmpEntity.create!(entity: source_person, cmp_id: Faker::Number.unique.number(digits: 6).to_i, entity_type: :person)
      end

      it 'transfers cmp entity' do
        cmp_entity
        merger.merge!
        expect(cmp_entity.reload.entity).to eql dest_person
      end
    end

    context 'when both source and dest person are cmp entities' do
      before do
        CmpEntity.create!(entity: source_person, cmp_id: Faker::Number.unique.number(digits: 6).to_i, entity_type: :person)
        CmpEntity.create!(entity: dest_person, cmp_id: Faker::Number.unique.number(digits: 6).to_i, entity_type: :person)
      end

      it 'does not merge and raises error instead' do
        expect { merger.merge! }.to raise_error(EntityMerger::MergingTwoCmpEntitiesError)
      end
    end
  end

  describe 'NY donations' do
    subject(:merger) { EntityMerger.new(source: source_person, dest: dest_person) }

    let(:filer_id) { SecureRandom.hex(2) }
    let(:ny_filer) { create(:ny_filer, filer_id: filer_id) }
    let(:nys_politician) { create(:entity_person) }
    let(:ny_disclosures) { Array.new(2) { create(:ny_disclosure, filer_id: filer_id) } }

    context 'when the source has two ny matches' do
      before do
        NyFilerEntity.create!(filer_id: filer_id, entity_id: nys_politician.id, ny_filer: ny_filer)
        ny_disclosures.map(&:id).map { |i| NyMatch.match(i, source_person.id) }
      end

      it 'transfers matches' do
        expect(NyMatch.where(donor_id: source_person.id).count).to eq 2
        expect(NyMatch.where(donor_id: dest_person.id).count).to eq 0
        merger.merge!
        expect(NyMatch.where(donor_id: source_person.id).count).to eq 0
        expect(NyMatch.where(donor_id: dest_person.id).count).to eq 2
      end
    end

    context 'when source is a ny politician' do
      let(:random_donor) { create(:entity_person) }
      let(:matches) { ny_disclosures.map { |nyd| NyMatch.match(nyd.id, random_donor.id) } }
      let(:relationship) { matches.first.relationship }

      before do
        NyFilerEntity.create!(filer_id: filer_id, entity_id: source_person.id, ny_filer: ny_filer)
      end

      it 'changes ny_matches' do
        matches.each { |m| expect(m.recip_id).to eql source_person.id }
        merger.merge!
        matches.each { |m| expect(m.reload.recip_id).to eql dest_person.id }
      end

      it 'updates the relationship' do
        expect(relationship.entity2_id).to eq source_person.id
        merger.merge!
        expect(relationship.reload.entity2_id).to eq dest_person.id
      end

      it 'changes the NyFilerEntity' do
        expect(NyFilerEntity.find_by(entity_id: source_person.id).nil?).to be false
        expect(NyFilerEntity.find_by(entity_id: dest_person.id).nil?).to be true
        merger.merge!
        expect(NyFilerEntity.find_by(entity_id: source_person.id).nil?).to be true
        expect(NyFilerEntity.find_by(entity_id: dest_person.id).nil?).to be false
      end
    end
  end # end nys donations

  describe 'external links' do
    context 'when source has an external link' do
      let!(:external_link) do
        ExternalLink.create!(link_type: 'sec', link_id: rand(10_000).to_s, entity: source_org)
      end

      it 'transfers external links from source to dest' do
        expect { EntityMerger.new(source: source_org, dest: dest_org).merge! }.not_to change(ExternalLink, :count)

        last_link = ExternalLink.last
        expect(last_link.link_id).to eq external_link.link_id
        expect(last_link.entity).to eq dest_org
      end
    end

    context 'when source and dest have an external link of different types' do
      let(:external_links) do
        {
          source: ExternalLink.create!(link_type: 'sec', link_id: rand(10_000).to_s, entity: source_org),
          dest: ExternalLink.create!(link_type: 'wikipedia', link_id: 'wiki_page', entity: dest_org)
        }
      end

      before { external_links }

      it 'transfers external links from source to dest' do
        expect do
          EntityMerger.new(source: source_org, dest: dest_org).merge!
        end.to change { dest_org.reload.external_links.count }.from(1).to(2)
      end
    end

    context 'when source and dest have an external link of the same types' do
      let(:external_links) do
        {
          source: ExternalLink.create!(link_type: 'wikipedia', link_id: 'wiki_page', entity: source_org),
          dest: ExternalLink.create!(link_type: 'wikipedia', link_id: 'other_wiki_page', entity: dest_org)
        }
      end

      before { external_links }

      it 'does not transfer external links from source to dest' do
        expect { EntityMerger.new(source: source_org, dest: dest_org).merge! }.to raise_error(EntityMerger::ConflictingExternalLinksError)
        expect(external_links[:source].reload.entity_id).to eq source_org.id
      end
    end
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
