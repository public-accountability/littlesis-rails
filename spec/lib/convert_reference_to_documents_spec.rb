require 'rails_helper'
require Rails.root.join('db', 'migrate', '20171012181822_convert_legacy_references_to_documents.rb')

describe 'convert_reference_to_documents.sql' do
  before(:all) do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents")
    LegacyReference.delete_all
    ReferenceExcerpt.delete_all

    @entity = create(:entity_org, last_user_id: 1)

    # Create 4 references, with 3 uniqiue URLS
    # ref2 and ref3 have the same url
    @ref1 = LegacyReference.create!(source: 'http://littlesis.org/A', name: 'A', object_id: @entity.id, object_model: 'Entity')
    @ref2 = LegacyReference.create!(source: 'http://littlesis.org/B', name: 'B-SOURCE-1', object_id: @entity.id, object_model: 'Entity')
    @ref3 = LegacyReference.create!(source: 'http://littlesis.org/B', name: 'B-SOURCE-2', object_id: @entity.id, object_model: 'Entity')
    # whitespace is intentional...testing that the sql trims the urls.
    @ref4 = LegacyReference.create!(source: '  http://littlesis.org/C', name: 'C', object_id: @entity.id, object_model: 'Entity', ref_type: 3)

    # Set ref2 and ref3's updated at and created_at columns
    @ref2.update_columns(updated_at: 1.week.ago, created_at: 1.week.ago)
    @ref3.update_columns(updated_at: 1.year.ago, created_at: 1.year.ago)

    # Create 3 Reference Excerpts, with 2 uniqiue urls
    @excerpt1 = ReferenceExcerpt.create!(reference_id: @ref1.id, body: 'blah blah blah')
    @excerpt2 = ReferenceExcerpt.create!(reference_id: @ref2.id, body: 'B-EXCERPT-1')
    @excerpt3 = ReferenceExcerpt.create!(reference_id: @ref3.id, body: 'B-EXCERPT-2')
  end

  after(:all) do
    [@entity, @ref1, @ref2, @ref3, @ref4, @excerpt1, @excerpt2, @excerpt3].each(&:delete)
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents")
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
      expect(Document.find_by_url('http://littlesis.org/c').excerpt).to be nil
    end
  end
end
