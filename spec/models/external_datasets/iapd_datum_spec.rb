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

  describe 'IapdDatum.owners and IapdDatum.advisors' do
    let(:owner) { create(:external_dataset_iapd_owner) }
    let(:advisor) { create(:external_dataset_iapd_advisor) }

    before { owner; advisor; }

    specify { expect(IapdDatum.owners.count).to eq 1 }
    specify { expect(IapdDatum.advisors.count).to eq 1 }
    specify { expect(IapdDatum.owners.first).to eq owner }
    specify { expect(IapdDatum.advisors.first).to eq advisor }
  end
end
