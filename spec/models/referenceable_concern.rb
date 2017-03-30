require 'rails_helper'

describe 'Referenceable' do
  describe '#references' do
    before do
      @org = build(:org, id: rand(100))
      @refs = double('references')
      expect(Reference).to receive(:where).with(object_model: 'Entity', object_id: @org.id).and_return(@refs)
    end

    it 'by default, it returns all references' do
      expect(@refs).not_to receive(:limit)
      expect(@refs).not_to receive(:order)
      expect(@org.references).to eq @refs
    end

    it 'returns refs with limit when passed option :limit' do
      expect(@refs).to receive(:limit).with(10).and_return(@refs)
      expect(@refs).not_to receive(:order)
      expect(@org.references(limit: 10)).to eq @refs
    end

    it 'returns references with descending order when passed option :order => true' do
      expect(@refs).to receive(:order).with('updated_at DESC').and_return(@refs)
      expect(@refs).not_to receive(:limit)
      expect(@org.references(order: true)).to eq @refs
    end

    it 'can return references with both options - limit and order' do
      expect(@refs).to receive(:order).with('updated_at DESC').and_return(@refs)
      expect(@refs).to receive(:limit).with(10).and_return(@refs)
      expect(@org.references(order: true, limit: 10)).to eq @refs
    end
  end
end
