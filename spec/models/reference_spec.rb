require 'rails_helper'

describe Reference do
  describe 'ref_types' do
    it 'has ref_types class var' do
      r = Reference.new
      expect(r.ref_types[1]).to eql('Generic')
      expect(r.ref_types[2]).to eql('FEC Filing')
    end

    it 'has a ref_type default value of 1' do
      r = create(:ref, source: 'url', object_id: 1)
      expect(r.ref_type).to eq(1)
    end
  end

  describe 'validations' do
    it { should validate_length_of(:source).is_at_most(1000) }
    it { should validate_length_of(:source_detail).is_at_most(255) }
    it { should validate_presence_of(:source) }
    it { should validate_presence_of(:object_id) }
    it { should validate_presence_of(:object_model) }
  end

  describe 'validate_before_create' do
    it 'returns errors hash if missing source' do
      expect(Reference.new.validate_before_create).to have_key :source
    end

    it 'returns errors hash if missing name' do 
      expect(Reference.new(source: 'http://example.com').validate_before_create).to have_key :name
      expect(Reference.new.validate_before_create).to have_key :name
    end

    it 'returns errors hash if source or name is a blank string' do
      expect(Reference.new(source: '').validate_before_create).to have_key :source
      expect(Reference.new(name: '').validate_before_create).to have_key :name
    end

    it 'returns empty hash if there are no errors' do
      expect(Reference.new(source: 'http://example.com', name: 'resource name')
              .validate_before_create.empty?).to be true
    end
  end

  # describe 'recent_references' do
  #   def where_double(order_double = nil)
  #     order_double = double( :limit => nil) if order_double.nil?
  #     double('wheres', :order => order_double)
  #   end

  #   it 'generates correct query if passed an hash' do
  #     o = { object_model: 'Relationship', object_id: 123 }
  #     expect(Reference).to receive(:where).with("(object_model = 'Relationship' AND object_id = 123)").and_return(where_double)
  #     Reference.recent_references(o)
  #   end

  #   it 'generates correct query if passed an array of hashes' do
  #     objs = [ { object_model: 'Relationship', object_id: 123 }, { object_model: 'Entity', object_id: 456 } ] 
  #     expect(Reference).to receive(:where).with("(object_model = 'Relationship' AND object_id = 123) OR (object_model = 'Entity' AND object_id = 456)").and_return(where_double)
  #     Reference.recent_references(objs)
  #   end

  #   it 'generates correct query if passed an array of Active Record Models' do
  #     objs = [Relationship.new(id: 123), Entity.new(id: 456)]
  #     expect(Reference).to receive(:where).with("(object_model = 'Relationship' AND object_id = 123) OR (object_model = 'Entity' AND object_id = 456)").and_return(where_double)
  #     Reference.recent_references(objs)
  #   end

  #   it 'Sets default limit to 20' do
  #     order_double = double('order')
  #     expect(order_double).to receive(:limit).with(20)
  #     expect(Reference).to receive(:where).and_return(where_double(order_double))
  #     Reference.recent_references([Relationship.new(id: 123)])
  #   end

  #   it 'Changes the limit' do
  #     order_double = double('order')
  #     expect(order_double).to receive(:limit).with(100)
  #     expect(Reference).to receive(:where).and_return(where_double(order_double))
  #     Reference.recent_references([ Relationship.new(id: 123) ], 100)
  #   end

  #   it 'raises exception if incorrect type is passed' do
  #     expect { Reference.recent_references(['HEY']) }.to raise_error(ArgumentError)
  #   end
  # end

  describe 'recent_references' do
    describe 'generate_where' do
      it 'produces correct sql string' do
        h = { class_name: 'Entity', object_ids: [4,5,6] }
        expect(Reference.send(:generate_where, h)).to eq "( object_model = 'Entity' AND object_id IN (4,5,6) )"
      end
    end

    it 'raises Argument Error if passed something other than an Array or Hash' do
      expect { Reference.recent_references(Entity) }.to raise_error(ArgumentError)
    end

    it 'when provided hash, it calls Reference.where correctly' do
      hash = { :class_name => 'Entity', :object_ids => [1,2,3] }
      expect(Reference).to receive(:where)
                            .with("( object_model = 'Entity' AND object_id IN (1,2,3) )")
                            .and_return( double(order: double(limit: nil)))

      Reference.recent_references(hash)
    end

    it 'when provided array, it calls Reference.where correctly' do
      hash = [{ :class_name => 'Entity', :object_ids => [1,2,3] }, { :class_name => 'Relationship', :object_ids => [4,5,6] } ]
      limit_double = double('limit')
      expect(limit_double).to receive(:limit).with(20)
      expect(Reference).to receive(:where)
                            .with("( object_model = 'Entity' AND object_id IN (1,2,3) ) OR ( object_model = 'Relationship' AND object_id IN (4,5,6) )")
                            .and_return( double(order: limit_double))

      Reference.recent_references(hash)
    end

    it 'it can change limit' do
      hash = { :class_name => 'Entity', :object_ids => [1,2,3] }
      limit_double = double('limit')
      expect(limit_double).to receive(:limit).with(100)
      expect(Reference).to receive(:where)
                            .with("( object_model = 'Entity' AND object_id IN (1,2,3) )")
                            .and_return( double(order: limit_double))

      Reference.recent_references(hash, 100)
    end
  end

end
