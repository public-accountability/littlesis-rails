require 'rails_helper'

describe 'convert_reference_to_documents.sql' do
  before(:all) do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents")
    LegacyReference.delete_all
    ReferenceExcerpt.delete_all
    
    @entity = create(:entity_org, last_user_id: 1)

    # Create 4 references, with 3 uniqiue URLS
    # ref2 and ref3 have the same url
    @ref1 = LegacyReference.create!(source: 'http://littlesis.org/A', name: 'A', object_id: @entity.id, object_model: 'Entity')
    @ref2 = LegacyReference.create!(source: 'http://littlesis.org/B', name: 'B', object_id: @entity.id, object_model: 'Entity')
    @ref3 = LegacyReference.create!(source: 'http://littlesis.org/B', name: 'B', object_id: @entity.id, object_model: 'Entity')
    @ref4 = LegacyReference.create!(source: 'http://littlesis.org/C', name: 'C', object_id: @entity.id, object_model: 'Entity')

    # Create 3 Reference Excerpts, with 2 uniqiue urls
    @excerpt1 = ReferenceExcerpt.create!(reference_id: @ref1.id, body: 'blah blah blah')

    @excerpt2 = ReferenceExcerpt.create!(reference_id: @ref2.id, body: 'B-1')
    @excerpt3 = ReferenceExcerpt.create!(reference_id: @ref3.id, body: 'B-2')
  end

  after(:all) do
    [@entity, @ref1, @ref2, @ref3, @ref4, @excerpt1, @excerpt2, @excerpt3].each { |x| x.delete }
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents")
  end

  describe 'transfering legacy references to documents' do
    before(:all) do
      sql = File.read(Rails.root.join('lib', 'sql', 'convert_reference_to_documents.sql'))
      sql.split(';').map(&:strip).each do |statement|
        ActiveRecord::Base.connection.execute(statement) unless statement.blank?
      end
    end

    it 'creates 3 documents' do
      expect(Document.count).to eq 3
    end
  end
end
