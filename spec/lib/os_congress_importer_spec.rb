require 'os_congress_importer'

describe 'OsCongressImporter' do
  before(:all) do
    Entity.skip_callback(:create, :after, :create_primary_ext)
  end

  after(:all) do
    Entity.set_callback(:create, :after, :create_primary_ext)

  end

  describe '#get_entity_id' do
    before(:all) do
      DatabaseCleaner.start
      create(:elected, id: 10000)
      create(:elected, id: 20000)
      @elected = create(:elected)
      @elected2 = create(:elected)
      @rep = create(:elected_representative, entity_id: @elected.id, crp_id: '1234')
      @candidate = create(:political_candidate, entity_id: @elected2.id, crp_id: '5678')
      @candidate2 = create(:political_candidate, entity_id: @elected2.id, house_fec_id: 'H6')
      @importer = OsCongressImporter.new 'path', Rails.root.join('spec', 'testdata', 'members114_ids.csv')
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    it 'returns id if a elected rep is found' do
      id = @importer.get_entity_id({'CID'=>'1234'})
      expect(id).to eql @elected.id
    end

    it 'returns id if Political Candidate is found' do
      id = @importer.get_entity_id({'CID'=>'5678'})
      expect(id).to eql @elected2.id
    end

    it 'returns id if political candidate has correct house_fec_number' do
      id = @importer.get_entity_id({'CID'=>'xxxxxx', 'FECCandID'=>'H6'})
      expect(id).to eql @elected2.id
    end

    it 'finds id in lookup chart and creates elected resp' do
      expect(@importer.get_entity_id({'CID'=>'N00036633'})).to eql 10000
      expect(@importer.get_entity_id({'CID'=>'N00035451'})).to eql 20000
      expect(ElectedRepresentative.find_by(entity_id: 10000).crp_id).to eql('N00036633')
      expect(ElectedRepresentative.find_by(entity_id: 20000).crp_id).to eql('N00035451')
    end

  end

  describe '#create_114_list' do
    it 'creates list after initializing' do
        importer = OsCongressImporter.new 'path'
        expect(List.find(importer.list_id).name).to eql('114th Congress')
    end
  end

  describe 'processing test file' do

    before(:all) do
      DatabaseCleaner.start
      create(:us_house)
      @Abraham = create(:elected)
      @Aderholt = create(:elected, id: 20000)
      @candidate = create(:political_candidate, entity_id: @Abraham.id, crp_id: 'N00036633')
      @relationship = create(:relationship_with_house, entity1_id: @Abraham.id)
      @importer = OsCongressImporter.new Rails.root.join('spec', 'testdata', 'members114_sample.csv'), Rails.root.join('spec', 'testdata', 'members114_ids.csv')
      @importer.start
    end

    after(:all) do
      DatabaseCleaner.clean
    end

    describe "Abraham, Raplh" do
      it 'creates Elected Representative' do
        er = ElectedRepresentative.find_by(entity_id: @Abraham.id)
        expect(er).not_to be_nil
        expect(er.crp_id).to eql('N00036633')
      end

      it 'does not change existing relationship' do
        expect(Relationship.find_by(entity1_id: @Abraham.id).start_date).to eql('2012-00-00')
      end

    end

    describe "Aderholt, Robert B" do
      it 'creates Elected Representative' do
        er = ElectedRepresentative.find_by(entity_id: @Aderholt.id)
        expect(er).not_to be_nil
        expect(er.crp_id).to eql('N00035451')
      end

      it 'creates new relationship' do
        expect(Relationship.find_by(entity1_id: @Aderholt.id).start_date).to eql('2015-01-03')
      end


    end

    it 'adds two entities to the list' do
      expect(List.find(@importer.list_id).list_entities.length).to eql(2)
    end

  end
end
