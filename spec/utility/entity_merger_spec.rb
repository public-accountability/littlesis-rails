require 'rails_helper'

describe 'Merging Entities', :merging_helper do
  let(:source_org) { create(:entity_org, :with_org_name) }
  let(:dest_org) { create(:entity_org, :with_org_name) }
  let(:source_person) { create(:entity_person, :with_person_name) }
  let(:dest_person) { create(:entity_person, :with_person_name) }
  subject { EntityMerger.new(source: source_org, dest: dest_org) }

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

  it 'sets the "merged_id" fields of the merged entity to be the id of the merged entity'
  it 'marks the merged entity as deleted'

  context 'extensions' do
    subject { EntityMerger.new(source: source_person, dest: dest_person) }

    context 'With no new extensions on the source' do
      it '@extensions contains non-new extension' do
        subject.merge_extensions
        expect(subject.extensions.length).to eql 1
        extension = subject.extensions.first
        expect(extension).to be_a EntityMerger::Extension
        expect(extension.new).to be false
        expect(extension.ext_id).to eql 1
        expect(extension.fields).to eql source_person.person.attributes.except('id', 'entity_id')
      end
    end

    context 'when the source has a new extension with fields' do
      before do
        source_person.add_extension('PoliticalCandidate') # ext_id = 3
        source_person.person.update(name_middle: 'MIDDLE')
        subject.merge_extensions
      end

      it 'has 2 extensions' do
        expect(subject.extensions.length).to eql 2
      end

      it 'has new extension' do
        new_ext = subject.extensions.select { |e| e.new == true }.first
        expect(new_ext.new).to be true
        expect(new_ext.ext_id).to eql 3
        expect(new_ext.fields.keys).to contain_exactly('is_federal', 'is_state', 'is_local', 'pres_fec_id', 'senate_fec_id', 'house_fec_id', 'crp_id') 
      end

      merge! do
        it 'adds new extenion to destination' do
          expect { subject.merge! }
            .to change { Entity.find(dest_person.id).extension_names }.from(['Person']).to(['Person', 'PoliticalCandidate'])
        end

        it 'updates attributes of existing extensions' do
          expect { subject.merge! }
            .to change { Entity.find(dest_person.id).person.name_middle }
                  .from(nil).to('MIDDLE')
        end

        it 'doest not update non-nil attributes of existing extensions' do
          expect { subject.merge! }
            .not_to change { Entity.find(dest_person.id).person.name_first }
        end
      end
    end

    context 'when the source has a new extension without fields' do
      subject { EntityMerger.new(source: source_org, dest: dest_org) }
      before do
        source_org.add_extension('Philanthropy') # ext_id = 9
        subject.merge_extensions
      end

      it { expect(subject.extensions.length).to eql 2 }

      it 'contains new philanthroy extension' do
        new_ext = subject.extensions.select { |e| e.new == true }.first
        expect(new_ext.ext_id).to eql 9
        expect(new_ext.fields).to eql({})
      end

      merge! do
        it 'adds new extension to the destination' do
          expect { subject.merge! }
            .to change { Entity.find(dest_org.id).has_extension?('Philanthropy') }.from(false).to(true)
        end
      end
    end
  end

  context 'contact info' do
    subject { EntityMerger.new(source: source_org, dest: dest_org) }

    context 'addresses' do
      let!(:address) { create(:address, entity_id: source_org.id) }

      context 'source has a new address' do
        before { subject.merge_contact_info }
        it 'duplicates address and appends to @contact_info' do
          verify_contact_info_length_type_and_entity_id(Address, dest_org.id)
        end
      end

      context 'source has an addresses that is the same as the destination adddress' do
        before do
          expect(dest_org).to receive(:addresses).and_return(double(:present? => true))
          expect(dest_org).to receive(:addresses).and_return([address.dup])
          subject.merge_contact_info
        end
        it 'skipped already existing address' do
          expect(subject.contact_info.length).to be_zero
        end
      end
    end

    context 'email' do
      let!(:email) { create(:email, entity_id: source_org.id) }
      context 'source has an new email' do
        before { subject.merge_contact_info }

        it 'duplicates email and appends to @contact_info' do
          verify_contact_info_length_type_and_entity_id(Email, dest_org.id)
        end
      end
      context 'dest has email with same address' do
        before do
          create(:email, address: email.address, entity_id: dest_org.id)
          subject.merge_contact_info
        end
        specify { expect(subject.contact_info.length).to be_zero }
      end
    end

    context 'phone' do
      let!(:phone) { create(:phone, entity_id: source_org.id) }
      context 'source has an new phone' do
        before { subject.merge_contact_info }

        it 'duplicates phone and appends to @contact_info' do
          verify_contact_info_length_type_and_entity_id(Phone, dest_org.id)
        end
      end

      context 'dest has phone with same number' do
        before do
          create(:phone, number: phone.number, entity_id: dest_org.id)
          subject.merge_contact_info
        end
        specify { expect(subject.contact_info.length).to be_zero }
      end
    end

    # it 'adds addresses to the destination entity'
    # it 'adds emails to destination entity'
    # it 'adds phone numbers to the destination entity'
  end

  context 'lists' do
    subject { EntityMerger.new(source: source_org, dest: dest_org) }
    let(:list1) { create(:list) }
    let(:list2) { create(:open_list) }
    let(:list3) { create(:closed_list) }

    it '@lists is empty by default' do
      expect(subject.lists).to eql []
      subject.merge_lists
      expect(subject.lists).to eql Set.new
    end

    context 'source is on two lists that the destination is not on' do
      before do
        ListEntity.create!(list_id: list1.id, entity_id: source_org.id)
        ListEntity.create!(list_id: list2.id, entity_id: source_org.id)
        ListEntity.create!(list_id: list3.id, entity_id: dest_org.id)
        subject.merge_lists
      end

      it '@lists contains a set of new list_ids' do
        expect(subject.lists).to eql([list1.id, list2.id].to_set)
      end
    end

    context 'source and dest is on the same list' do
      before do
        ListEntity.create!(list_id: list1.id, entity_id: source_org.id)
        ListEntity.create!(list_id: list1.id, entity_id: dest_org.id)
        subject.merge_lists
      end
      specify { expect(subject.lists).to be_empty }
    end

    # it 'adds the destination entity to the lists of the source entity'
    # it 'removes the source entity from it\'s lists'
  end

  context 'images' do
    subject { EntityMerger.new(source: source_org, dest: dest_org) }
    let!(:image) { create(:image, entity_id: source_org.id) }
    before { subject.merge_images }

    it 'changes images entity id' do
      expect(subject.images.length).to eql 1
      expect(subject.images.first).to be_a Image
      expect(subject.images.first.entity_id).to eql dest_org.id
    end
  end

  context 'aliases' do
    context 'no new aliases' do
      before do
        dest_org.aliases.create!(name: source_org.name)
        subject.merge_aliases
      end
      specify { expect(subject.aliases).to eql [] }
    end

    context 'source has 1 new aliases' do
      let(:corp_name) { Faker::Company.unique.name }
      before do
        dest_org.aliases.create!(name: source_org.name)
        source_org.aliases.create!(name: corp_name)
        subject.merge_aliases
      end

      it 'adds new aliases to @aliases' do
        expect(subject.aliases.length).to eql 1
        expect(subject.aliases.first).to be_a Alias
        expect(subject.aliases.first.name).to eql corp_name
        expect(subject.aliases.first.entity_id).to eql dest_org.id
        expect(subject.aliases.first.persisted?).to be false
      end
    end
  end

  context 'references/documents' do
    subject { EntityMerger.new(source: source_person, dest: dest_person) }
    let(:document) { create(:document) }

    context 'no new documents' do
      before do
        source_person.add_reference(url: document.url)
        dest_person.add_reference(url: document.url)
        dest_person.add_reference(url: Faker::Internet.url)
        subject.merge_references
      end

      it 'does not add new documents ids' do
        expect(subject.document_ids).to be_empty
      end
    end

    context 'new document' do
      before do
        source_person.add_reference(url: document.url)
        subject.merge_references
      end

      it 'adds one new documents ids' do
        expect(subject.document_ids.length).to eql 1
        expect(subject.document_ids.first).to eql document.id
      end
    end
  end

  context 'tags' do
    let(:tags) { Array.new(2) { create(:tag) } }

    context 'source and dest have the same tag' do
      before do
        source_org.add_tag(tags.first.id)
        dest_org.add_tag(tags.first.id)
        subject.merge_tags
      end
      specify { expect(subject.tag_ids).to eql Set.new }
    end

    context 'source and dest have the diffferent' do
      before do
        source_org.add_tag(tags.second.id)
        dest_org.add_tag(tags.first.id)
        subject.merge_tags
      end

      it 'adds tag to list of tag ids' do
        expect(subject.tag_ids).to eql Set.new([tags.second.id])
      end
    end
  end
#  it 'transfers images from the source to the destination entity'
#  it 'transfers aliases (if they do not already exist)'

  context 'articles' do
    subject { EntityMerger.new(source: source_org, dest: dest_org) }
    let(:article) { create(:article) }

    context 'source has no articles' do
      before { subject.merge_articles }
      specify { expect(subject.articles).to eql [] }
    end

    context 'source has article not on destination' do
      before do
        ArticleEntity.create!(article_id: article.id, entity_id: source_org.id)
        subject.merge_articles
      end

      it 'changes article entity id' do
        expect(subject.articles.length).to eql 1
        expect(subject.articles.first).to be_a ArticleEntity
        expect(subject.articles.first.entity_id).to eql dest_org.id
        expect(subject.articles.first.article_id).to eql article.id
      end
    end

    context 'both source and  destination entities have the same article' do
      before do
        ArticleEntity.create!(article_id: article.id, entity_id: source_org.id)
        ArticleEntity.create!(article_id: article.id, entity_id: dest_org.id)
        subject.merge_articles
      end

      it 'sets @articles to be an empty arry' do
        expect(subject.articles.length).to eql 0
        expect(subject.articles).to eql []
      end
    end
  end

  context 'Os Entity Category' do
    subject { EntityMerger.new(source: source_org, dest: dest_org) }
    let(:os_category) { build(:os_category_private_equity) }

    context 'new category id' do
      before do
        OsEntityCategory.create!(category_id: os_category.category_id, entity_id: source_org.id, source: 'OpenSecrets')
        subject.merge_os_categories
      end

      it 'changes os_entity_category entity id' do
        expect(subject.os_categories.length).to eql 1
        expect(subject.os_categories.first).to be_a OsEntityCategory
        expect(subject.os_categories.first.entity_id).to eql dest_org.id
      end
    end

    context 'no new category id' do
      before do
        OsEntityCategory.create!(category_id: os_category.category_id, entity_id: source_org.id, source: 'OpenSecrets')
        OsEntityCategory.create!(category_id: os_category.category_id, entity_id: dest_org.id, source: 'OpenSecrets')
        subject.merge_os_categories
      end

      it '@os_categories is empty' do
        expect(subject.os_categories).to be_empty
      end
    end
  end

  describe 'merging relationships' do
    let(:other_org) { create(:entity_org, :with_org_name) }

    context 'source has 2 relationships' do
      let!(:donation_relationship) { create(:donation_relationship, entity: source_org, related: other_org) }
      let!(:generic_relationship) { create(:generic_relationship, entity: other_org, related: source_org) }
      before { subject.merge_relationships }

      it 'populates @relationships with unsaved new relationships' do
        expect(subject.relationships.length).to eql 2
        expect(subject.potential_duplicate_relationships).to be_empty
      end

      it 'changes entity ids' do
        donation, generic = subject.relationships.sort_by { |r| r.category_id }
        expect(donation.entity1_id).to eql dest_org.id
        expect(donation.entity2_id).to eql other_org.id
        expect(donation.category_id).to eql 5
        expect(donation.persisted?).to be false
        expect(generic.entity1_id).to eql other_org.id
        expect(generic.entity2_id).to eql dest_org.id
        expect(generic.persisted?).to be false
      end
    end

    context 'source has 2 relationships, one is a os match relationship' do
      before do
        create(:generic_relationship, entity: other_org, related: source_org)
        donation_relationship = create(:donation_relationship, entity: source_org, related: other_org)
        OsMatch.create!(os_donation_id: create(:os_donation).id, donor_id: source_org.id, relationship_id: donation_relationship.id)
        subject.merge_relationships
      end

      it 'skips os match relationships' do
        expect(source_org.relationships.count).to eql 2
        expect(subject.relationships.length).to eql 1
      end
    end

    describe 'souce has 2 relationship, one is a duplicate' do
      before do
        create(:membership_relationship, entity: source_org, related: other_org)
        create(:membership_relationship, entity: dest_org, related: other_org)
        create(:generic_relationship, entity: other_org, related: source_org)
        subject.merge_relationships
      end

      it 'populates @relationships with unsaved new relationships' do
        expect(subject.relationships.length).to eql 2
      end

      it 'stores potential duplicate relationship' do
        expect(subject.potential_duplicate_relationships.length).to eql 1
        r = subject.potential_duplicate_relationships.first
        expect(r.triplet).to eql([dest_org.id, other_org.id, Relationship::MEMBERSHIP_CATEGORY])
      end
    end
  end

  context 'os donations' do
    it 'unmatches the os donations from the source entity'
    it 'matches those donations on the destination entity'
  end

  context 'ny donations' do
    it 'unmatches the ny donations from the source entity'
    it 'matches those donations on the destination entity'
  end

  context 'relationships' do
    context 'when a relationship exists on the source but not the destination' do
      it 'creates a new reference on the destination'
      it 'deletes the relationship from the source'
      it 'transfers the references from the relationship'
    end

    context 'when a relationship exists on both' do
      it 'does not create a new relationship'
      it 'deletes the relationship from the source'
      it 'updates fields on the existing relationship if the are null'
      it 'copies references from the source relationship'
    end
  end
end

