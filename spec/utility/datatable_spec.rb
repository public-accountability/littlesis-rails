require 'rails_helper'

# rubocop:disable RSpec/NestedGroups, RSpec/ImplicitSubject

describe Datatable do
  describe Datatable::Request do
    describe 'initialize' do
      subject(:request) { Datatable::Request.new(params) }

      let(:search) { nil }

      let(:columns) do
        [{ 'data' => 'first_name' }, { 'data' => 'last_name' }]
      end

      let(:params) do
        { 'draw' => '10',
          'start' => '100',
          'length' => '50',
          'search' => search,
          'columns' => columns }
      end

      specify { expect(request.draw).to eq 10 }
      specify { expect(request.start).to eq 100 }
      specify { expect(request.length).to eq 50 }
      specify { expect(request.frozen?).to be true }
      specify { expect(request.search).to be nil }
      specify { expect(request.columns).to eq %w[first_name last_name] }

      context 'with search term' do
        let(:search) { { 'value' => 'alice' } }

        specify { expect(request.search).to eq 'alice' }
      end

      context 'with empty seach term' do
        let(:search) { { 'value' => '' } }

        specify { expect(request.search).to be nil }
      end
    end
  end

  describe Datatable::Response do
    describe '.for' do
      context 'when called with :NyFiler' do
        subject { Datatable::Response.for(:NyFiler) }

        it { is_expected.to be_a Class }
        assert_attribute :superclass, Datatable::Response
      end
    end

    describe 'handling request for NyFiler' do
      subject { Datatable::Response.for(:NyFiler).new(request).json }

      let(:ny_filers) { Array.new(2) { create(:ny_filer) } }

      let(:request) do
        Datatable::Request.new({ 'draw' => '1',
                                 'start' => '0',
                                 'length' => '3',
                                 'columns' => [{ 'data' => 'filer_id' }, { 'data' => 'name' }] })
      end

      let(:data) do
        ny_filers
          .sort_by(&:id)
          .reverse!
          .map { |filer| filer.attributes.slice('filer_id', 'name').merge('entity_matches' => []) }
      end

      before do
        ny_filers
        UnmatchedNyFiler.recreate!
        allow(EntityMatcher::NyFiler).to receive(:matches).and_return([])
      end

      it do
        is_expected
          .to eq('draw' => 1,
                 'recordsTotal' => 2,
                 'recordsFiltered' => 2,
                 'data' => data)

      end
    end
  end
end

# rubocop:enable RSpec/NestedGroups, RSpec/ImplicitSubject

