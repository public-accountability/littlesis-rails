require 'rails_helper'

describe 'Kaminari patches' do
  let(:ids) { (0..3).to_a }
  describe "#map monkeypatch" do
    let(:options) { { total_count: 1, limit: 2, offset: 3, padding: 4 } }

    it 'preserves the PaginatableArray interface' do
      res = Kaminari.paginate_array(ids, options)
      expect(res.map { |x| x }).to be_a Kaminari::PaginatableArray
      expect(res.map { |x| x }.send(:get_options)).to eql res.send(:get_options)
    end
  end
end
