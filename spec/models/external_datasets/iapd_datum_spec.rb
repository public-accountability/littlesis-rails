require "rails_helper"

describe IapdDatum do
  specify { expect(IapdDatum::IapdAdvisor).is_a? Struct }
  specify { expect(IapdDatum::IapdOwner).is_a? Struct }

  describe 'name' do
    specify { expect(IapdDatum.new.name).to eq 'iapd' }
  end
end
