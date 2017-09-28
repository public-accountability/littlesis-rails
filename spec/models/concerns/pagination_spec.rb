require 'rails_helper'

describe 'Pagination Module' do
  include Pagination
  let(:ids) { (0..3).to_a }

  describe "#pagination" do
    it "shows a correct page" do
      expect(paginate(1, 2, ids)).to eql [0, 1]
      expect(paginate(2, 2, ids)).to eql [2, 3]
    end

    it "truncates a page to a page limit" do
      expect(paginate(1, 2, ids).size).to eq 2
    end

    it "returns a PaginatableArray" do
      expect(paginate(1, 2, ids)).to be_a Kaminari::PaginatableArray
    end

    it "returns a PaginatableArray after mapping" do
      expect(paginate(1, 2, ids)).to be_a Kaminari::PaginatableArray
      expect(paginate(1, 2, ids).map { |x| x }).to be_a Kaminari::PaginatableArray
    end
  end
end
