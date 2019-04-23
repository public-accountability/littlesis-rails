require "rails_helper"

describe IapdDatum do
  specify { expect(IapdDatum::IapdAdvisor).is_a? Struct }
  specify { expect(IapdDatum::IapdOwner).is_a? Struct }

  describe '#name' do
    specify { expect(IapdDatum.new.name).to eq 'iapd' }
  end

  describe '#owner? and #advisor?' do
    let(:iapd_owner) { build(:external_dataset_iapd_owner) }
    let(:iapd_advisor) { build(:external_dataset_iapd_advisor) }

    specify { expect(iapd_owner.owner?).to be true }
    specify { expect(iapd_owner.advisor?).to be false }
    specify { expect(iapd_advisor.owner?).to be false }
    specify { expect(iapd_advisor.advisor?).to be true }
  end
end
