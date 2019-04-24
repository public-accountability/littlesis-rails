require "rails_helper"

describe IapdDatum do
  let(:iapd_owner) { build(:external_dataset_iapd_owner) }
  let(:iapd_advisor) { build(:external_dataset_iapd_advisor) }

  specify { expect(IapdDatum::IapdAdvisor).is_a? Struct }
  specify { expect(IapdDatum::IapdOwner).is_a? Struct }

  describe '#name' do
    specify { expect(IapdDatum.new.name).to eq 'iapd' }
  end

  describe '#filing_ids' do
    specify do
      expect(iapd_advisor.filing_ids).to eq [1_243_455, 1_234_105, 1_172_226, 1_071_005]
    end

    specify do
      expect(iapd_owner.filing_ids).to eq [1_250_755]
    end
  end

  describe '#associated_advisors' do
    specify do
      expect { iapd_advisor.associated_advisors }.to raise_error(Exceptions::LittleSisError)
    end

    specify do
      expect(iapd_owner.associated_advisors).to eq [19_585]
    end
  end

  describe '#filings_for_advisor' do
    specify do
      expect(build(:external_dataset_iapd_owner).filings_for_advisor(19_585))
        .to eq(build(:external_dataset_iapd_owner).row_data['data'])
    end

    specify do
      expect(build(:external_dataset_iapd_owner).filings_for_advisor(123)).to eq([])
    end
  end

  describe '#owner? and #advisor?' do
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

  describe 'IapdDatum.owners_of_crd_number' do
    let(:owner_one) { create(:external_dataset_iapd_owner) }
    let(:owner_two) { create(:external_dataset_iapd_owner_without_crd) }

    before { owner_one; owner_two; }

    specify { expect(IapdDatum.owners_of_crd_number(19_585).count).to eq 2 }
    specify { expect(IapdDatum.owners_of_crd_number(5).count).to eq 0 }

    it 'finds corrects owner' do
      owners = IapdDatum.owners_of_crd_number(1_000).to_a
      expect(owners.size).to eq 1
      expect(owners.first).to eq owner_two
    end
  end
end
