require 'rails_helper'

describe LsSearch do
  describe 'escape' do
    specify { expect(LsSearch.escape('@person')).to eq '\\@person' }
    specify { expect(LsSearch.escape('"person"')).to eq '"person"' }
  end
end
