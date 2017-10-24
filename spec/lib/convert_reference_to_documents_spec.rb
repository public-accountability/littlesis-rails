require 'rails_helper'
require Rails.root.join('db', 'migrate', '20171012181822_convert_legacy_references_to_documents.rb')

describe 'migrating from the legacy reference system' do
  before(:all) do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents;")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE `references`")
    LegacyReference.delete_all
    ReferenceExcerpt.delete_all
    Entity.skip_callback(:create, :after, :create_primary_ext)
    Relationship.skip_callback(:create, :after, :create_links)

    @entities = Array.new(3) { create(:entity_org, last_user_id: 1) }
    @list = create(:list)
    @relationship = create(:generic_relationship, entity: @entities[1], related: @entities[2])

    # Create 5 references, with 3 uniqiue URLS
    # ref2 and ref3 have the same url
    # ref4 and ref5 have the same url
    # Ref 1 is for entity[0]
    # Ref 2 is for list
    # Ref 3,4, and 5 are for relationship
    #
    # These 5 legacy references should result in: 3 documents and 4 references
    #
    @ref1 = LegacyReference.create!(source: 'http://littlesis.org/A', name: 'A', object_id: @entities[0].id, object_model: 'Entity')
    @ref2 = LegacyReference.create!(source: 'http://littlesis.org/B', name: 'B-SOURCE-1', object_id: @list.id, object_model: 'LsList')
    @ref3 = LegacyReference.create!(source: 'http://littlesis.org/B', name: 'B-SOURCE-2', object_id: @relationship.id, object_model: 'Relationship')
    # whitespace is intentional...testing that the sql trims the urls.
    @ref4 = LegacyReference.create!(source: '  http://littlesis.org/C', name: 'C', object_id: @relationship.id, object_model: 'Relationship', ref_type: 3)
    @ref5 = LegacyReference.create!(source: '  http://littlesis.org/C', name: 'C', object_id: @relationship.id, object_model: 'Relationship')

    # Set ref2 and ref3's updated at and created_at columns
    @ref2.update_columns(updated_at: 1.week.ago, created_at: 1.week.ago)
    @ref3.update_columns(updated_at: 1.year.ago, created_at: 1.year.ago)

    # Create 3 Reference Excerpts, with 2 uniqiue urls
    @excerpt1 = ReferenceExcerpt.create!(reference_id: @ref1.id, body: 'blah blah blah')
    @excerpt2 = ReferenceExcerpt.create!(reference_id: @ref2.id, body: 'B-EXCERPT-1')
    @excerpt3 = ReferenceExcerpt.create!(reference_id: @ref3.id, body: 'B-EXCERPT-2')
  end

  after(:all) do
    (@entities + [@ref1, @ref2, @ref3, @ref4, @excerpt1, @excerpt2, @excerpt3]).each(&:delete)
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents")
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE `references`")
    Entity.set_callback(:create, :after, :create_primary_ext)
    Relationship.set_callback(:create, :after, :create_links)
  end

  describe 'transfering legacy references to documents' do
    before(:all) { ConvertLegacyReferencesToDocuments.up }
    let(:document) { Document.find_by_url('http://littlesis.org/B') }

    it 'creates 3 documents' do
      expect(Document.count).to eq 3
    end

    it 'selects name arbitrarily' do
      expect(%w[B-SOURCE-1 B-SOURCE-2].to_set).to include document.name
    end

    it 'calculates URL hashes' do
      expect(Document.find_by_url('http://littlesis.org/A').url_hash).to eql Digest::SHA1.hexdigest('http://littlesis.org/A')
      expect(Document.find_by_url('http://littlesis.org/B').url_hash).to eql Digest::SHA1.hexdigest('http://littlesis.org/B')
      expect(Document.find_by_url('http://littlesis.org/C').url_hash).to eql Digest::SHA1.hexdigest('http://littlesis.org/C')
    end

    it 'copies ref type' do
      expect(Document.find_by_url('http://littlesis.org/C').ref_type).to eql 3
    end

    it 'selects maxiumn updated_at date and minium created_at' do
      expect(document.updated_at.strftime('%F')).to eq 1.week.ago.strftime('%F')
      expect(document.created_at.strftime('%F')).to eq 1.year.ago.strftime('%F')
    end

    it 'adds the excerpt to the Document' do
      expect(Document.find_by_url('http://littlesis.org/A').excerpt).to eql 'blah blah blah'
      expect(Document.find_by_url('http://littlesis.org/B').excerpt).to eql 'B-EXCERPT-1'
      expect(Document.find_by_url('http://littlesis.org/C').excerpt).to be nil
    end
  end

  describe 'populating references table' do
    before(:all) do
      sql = File.read(Rails.root.join('lib', 'sql', 'populate_references.sql'))
      ActiveRecord::Base.connection.execute(sql)
    end

    it 'creates 4 references' do
      expect(Reference.count).to eql 4
    end

    it 'filters out duplicated urls-resource combinations' do
      expect(@relationship.references.count).to eql 2
      expect(@relationship.documents.count).to eql 2
      expect(@relationship.documents.map(&:url).to_set)
        .to eql Set.new(['http://littlesis.org/C', 'http://littlesis.org/B'])
    end

    it 'handle legacy list model name: LsList' do
      expect(@list.references.count).to eql 1
      expect(@list.references.first).to eql Reference.where(referenceable_id: @list.id, referenceable_type: 'List').first
      expect(@list.documents.first).to eql Document.find_by_url('http://littlesis.org/B')
    end
  end
end
