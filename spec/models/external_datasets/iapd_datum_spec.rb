# rubocop:disable Style/Semicolon

describe IapdDatum do
  let(:iapd_owner) { build_stubbed(:external_dataset_iapd_owner) }
  let(:iapd_advisor) { build_stubbed(:external_dataset_iapd_advisor) }

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

  describe '#filings' do
    specify do
      expect(build(:iapd_seth_klarman).filings.size).to eq 1
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

  describe 'match_with' do
    let(:seth_klarman_entity) { create(:entity_person, name: 'Seth Klarman') }
    let(:baupost_entity) { create(:entity_org, name: 'Baupost') }
    let(:iapd_seth_klarman) { create(:iapd_seth_klarman) }
    let(:iapd_baupost) { create(:iapd_baupost) }
    let(:tag) { create(:tag, name: "iapd") }

    before do
      stub_const("#{IapdDatum}::IAPD_TAG_ID", tag.id)
      baupost_entity
      iapd_baupost
      iapd_seth_klarman
    end

    describe 'matching advisor without matched entity' do
      it 'updates entity id' do
        expect(iapd_baupost.matched?).to be false
        iapd_baupost.match_with(baupost_entity)
        expect(iapd_baupost.matched?).to be true
        expect(iapd_baupost.entity_id).to eq baupost_entity.id
      end

      it 'returns array of IapdRelationshipService' do
        result = iapd_baupost.match_with(baupost_entity)
        expect(result.size).to eq 1
        expect(result.first).to be_a IapdRelationshipService
        expect(result.first.result).to eq :owner_not_matched
      end
    end

    describe 'matching advisor when owner has been matched' do
      before { iapd_seth_klarman.match_with(seth_klarman_entity) }

      it 'creates a new relationship' do
        expect { iapd_baupost.match_with(baupost_entity) }
          .to change(Relationship, :count).by(1)
      end

      it 'sets result to be :relationship_created' do
        result = iapd_baupost.match_with(baupost_entity)
        expect(result.first.result).to eq :relationship_created
      end

      it 'creates relationship with correct tag and attributes' do
        relationship = iapd_baupost.match_with(baupost_entity).first.relationship
        expect(relationship).to be_a Relationship
        expect(relationship.entity1_id).to eq seth_klarman_entity.id
        expect(relationship.entity2_id).to eq baupost_entity.id
        expect(relationship.tag_ids).to eq [tag.id]
      end
    end
  end

  describe 'add_to_matching_queue' do
    after { IapdDatum::OWNERS_MATCHING_QUEUE.clear }

    specify do
      expect { iapd_advisor.add_to_matching_queue }.to raise_error(Exceptions::LittleSisError)
    end

    it 'adds owner id to queue' do
      expect(IapdDatum::OWNERS_MATCHING_QUEUE.empty?).to be true
      iapd_owner.add_to_matching_queue
      expect(IapdDatum::OWNERS_MATCHING_QUEUE.fetch).to eq [iapd_owner.id]
    end

    it 'adds owner to queue twice only puts on copy in the queue' do
      2.times { iapd_owner.add_to_matching_queue }
      expect(IapdDatum::OWNERS_MATCHING_QUEUE.fetch).to eq [iapd_owner.id]
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

  describe 'advisors_by_crd_numbers' do
    before do
      create(:external_dataset_iapd_owner)
      create(:external_dataset_iapd_advisor, dataset_key: '123')
      create(:external_dataset_iapd_advisor, dataset_key: '456')
    end

    specify { expect(IapdDatum.advisors_by_crd_numbers('789').count).to eq 0 }
    specify { expect(IapdDatum.advisors_by_crd_numbers('123').count).to eq 1 }
    specify { expect(IapdDatum.advisors_by_crd_numbers(%w[123 456]).count).to eq 2 }
  end

  describe 'retrieving unmached_advisors' do
    let(:under_3_billion) { create(:external_dataset_iapd_advisor) }
    let(:over_3_billion) { create(:iapd_baupost) }

    before { under_3_billion; over_3_billion; }

    after { IapdDatum::UNMATCHED_ADVISOR_QUEUE.clear }

    describe 'priority_unmatched_advisors_ids' do
      specify do
        expect(IapdDatum.priority_unmatched_advisors_ids).to eq [over_3_billion.id]
      end
    end

    describe 'random_unmatch_advisor' do 
      it 'returns unmatched advisor' do
        expect(IapdDatum.random_unmatched_advisor).to eql over_3_billion
      end

      it 'finds non-priority if queue is empty unmatched advisor' do
        expect(IapdDatum.random_unmatched_advisor).to eql over_3_billion
        over_3_billion.update!(entity: create(:entity_org))
        expect(IapdDatum.random_unmatched_advisor).to eql under_3_billion
      end
    end
  end
end

# rubocop:enable Style/Semicolon
