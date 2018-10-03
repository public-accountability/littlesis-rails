require 'rails_helper'

describe Datatable do
  describe Datatable::Request do
    describe 'initialize' do
      subject(:request) { Datatable::Request.new(params) }

      let(:params) { { 'draw' => '10', 'start' => '100', 'length' => '50' } }

      specify { expect(request.draw).to eq 10 }
      specify { expect(request.start).to eq 100 }
      specify { expect(request.length).to eq 50 }
      specify { expect(request.frozen?).to be true }
    end
  end
end
