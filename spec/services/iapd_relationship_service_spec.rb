require "rails_helper"

# rubocop:disable RSpec/MultipleExpectations, RSpec/MessageSpies, RSpec/NestedGroups

describe IapdRelationshipService do
  describe 'initialize' do
    let(:advisor) { instance_double('IapdDatum') }
    let(:owner) { instance_double('IapdDatum') }
    let(:relationship) { instance_double('Relationship') }

    context 'when advisor is unmatched' do
      before do
        allow(advisor).to receive(:unmatched?).and_return(true)
      end

      it 'sets result to adivsor_not_matched' do
        service = IapdRelationshipService.new(advisor: advisor, owner: owner)
        expect(service.result).to eq :advisor_not_matched
        expect(service.relationship).to be nil
      end
    end

    context 'when owner is matched and advisor is matched' do
      before do
        allow(owner).to receive(:unmatched?).and_return(false)
        allow(advisor).to receive(:unmatched?).and_return(false)
      end

      it 'sets result properly when relationship exists' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(relationship)
        expect(IapdRelationshipService).not_to receive(:create_relationship)
        service = IapdRelationshipService.new(advisor: advisor, owner: owner)
        expect(service.result).to eq :relationship_exists
        expect(service.relationship).to eq relationship
      end

      it 'sets result and creates relationship when relationship does not exists' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(nil)
        expect(IapdRelationshipService).to receive(:create_relationship).and_return(relationship)
        service = IapdRelationshipService.new(advisor: advisor, owner: owner)
        expect(service.result).to eq :relationship_created
        expect(service.relationship).to eq relationship
      end

      it 'does not create a relationship when dry_run' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(nil)
        expect(IapdRelationshipService).not_to receive(:create_relationship)
        service = IapdRelationshipService.new(advisor: advisor, owner: owner, dry_run: true)
        expect(service.dry_run).to be true
        expect(service.result).to eq :relationship_created
      end

      it 'freezes the object' do
        expect(IapdRelationshipService).to receive(:find_relationship).and_return(relationship)
        expect(IapdRelationshipService.new(advisor: advisor, owner: owner)).to be_frozen
      end
    end

    context 'when owner is not matched' do
      before do
        allow(owner).to receive(:unmatched?).and_return(true)
        allow(advisor).to receive(:unmatched?).and_return(false)
      end

      it 'adds owner to matching queue' do
        expect(owner).to receive(:add_to_matching_queue).once
        IapdRelationshipService.new(advisor: advisor, owner: owner, dry_run: true)
      end

      it 'sets result to "owner_not_matched"' do
        allow(owner).to receive(:add_to_matching_queue)
        expect(IapdRelationshipService.new(advisor: advisor, owner: owner, dry_run: true).result)
          .to eq :owner_not_matched
      end
    end
  end

  describe 'Class methods' do
    describe 'Create_relationship' do
      describe 'errors' do
        let(:advisor) do
          instance_double('IapdDatum', :advisor? => true, :row_data => { 'crd_number' => 175_479 })
        end

        specify do
          expect do
            IapdRelationshipService.create_relationship(advisor: advisor,
                                                        owner: instance_double('IapdDatum', :owner? => true, :matched? => false, :org? => false))
          end.to raise_error(/not matched/)
        end

        specify do
          expect do
            IapdRelationshipService.create_relationship(advisor: advisor,
                                                        owner: instance_double('IapdDatum', :owner? => true, :matched? => true, :org? => true))
          end.to raise_error(/is an org/)
        end

        specify do
          expect do
            IapdRelationshipService.create_relationship(advisor: advisor,
                                                        owner: build(:external_dataset_iapd_owner_schedule_b, entity_id: 1))
          end.to raise_error(/No suitable filing/)
        end
      end

      describe 'Finding and Creating relationships' do
        let(:seth_klarman_entity) { create(:entity_person, name: 'Seth Klarman') }
        let(:baupost_entity) { create(:entity_org, name: 'Baupost') }
        let(:baupost_iapd) { create(:iapd_baupost).match_with(baupost_entity) }
        let(:klarman_iapd) { create(:iapd_seth_klarman).match_with(seth_klarman_entity) }
        let(:tag) { create(:tag, name: "iapd") }

        let(:create_service) do
          lambda do
            IapdRelationshipService.new(advisor: baupost_iapd, owner: klarman_iapd)
          end
        end

        before { stub_const("IapdRelationshipService::IAPD_TAG_ID", tag.id) }

        describe 'creating a relationship between Seth Klarman and Baupost' do
          it 'creates a new relationship' do
            expect(&create_service).to change(Relationship, :count).by(1)
          end

          it 'sets relationship fields correctly' do
            relationship = create_service.call.relationship
            expect(relationship.description1).to eq 'PARTNER AND CHIEF EXECUTIVE OFFICER'
            expect(relationship.category_id).to eq 1
            expect(relationship.entity1_id).to eq seth_klarman_entity.id
            expect(relationship.entity2_id).to eq baupost_entity.id
            expect(relationship.start_date).to eq "1998-01-00"
          end

          it 'adds iapd tag' do
            expect(create_service.call.relationship.tag_ids).to eq [tag.id]
          end

          it 'creates reference with correct url' do
            expect(create_service.call.relationship.documents.first.attributes.slice('name', 'url'))
              .to eq('name' => "Form ADV: 109530",
                     'url' => "https://www.adviserinfo.sec.gov/IAPD/content/ViewForm/crd_iapd_stream_pdf.aspx?ORG_PK=109530")
          end
        end

        describe 'find_relationships' do
          before do
            Relationship.create!(entity: seth_klarman_entity, related: create(:entity_org), category_id: 1)
          end

          it 'finds iapd tagged relationship' do
            relationship = create_service.call.relationship
            # IapdRelationshipService.new(advisor: baupost_iapd, owner: klarman_iapd)
            expect(IapdRelationshipService.find_relationship(advisor: baupost_iapd, owner: klarman_iapd))
              .to eq relationship
          end

          it 'returns nil if no relatinoship exists yet' do
            expect(IapdRelationshipService.find_relationship(advisor: baupost_iapd, owner: klarman_iapd))
              .to be nil
          end
        end
      end
    end

    describe 'create_relationships_for'
  end
end

# rubocop:enable RSpec/MultipleExpectations, RSpec/MessageSpies, RSpec/NestedGroups
