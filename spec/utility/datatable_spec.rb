require 'rails_helper'

# rubocop:disable RSpec/NestedGroups

describe Datatable do
  describe Datatable::Request do
    describe 'initialize' do
      subject(:request) { Datatable::Request.new(params) }

      let(:search) { nil }
      let(:params) { { 'draw' => '10', 'start' => '100', 'length' => '50', 'search' => search } }

      specify { expect(request.draw).to eq 10 }
      specify { expect(request.start).to eq 100 }
      specify { expect(request.length).to eq 50 }
      specify { expect(request.frozen?).to be true }
      specify { expect(request.search).to be nil }

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

    describe 'handling request' do
      
    end
  end
end

# rubocop:enable RSpec/NestedGroups
