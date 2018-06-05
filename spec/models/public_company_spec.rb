require 'rails_helper'

describe PublicCompany do
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to validate_length_of(:ticker).is_at_most(10) }
  it { is_expected.to have_db_column(:sec_cik) }

  describe 'create_or_update_external_link' do
    let(:entity) { create(:entity_org) }
    let(:cik) { Faker::Number.unique.number(6) }

    let(:create_public_company) do
      proc do
        entity
          .add_extension('PublicCompany', sec_cik: cik)
      end
    end

    it 'creates a new external link' do
      expect(&create_public_company).to change { ExternalLink.count }.by(1)
      expect(ExternalLink.last.link_id).to eql cik.to_s
    end

    it 'updates existing link' do
      ExternalLink.create!(entity: entity,
                           link_id: Faker::Number.unique.number(6),
                           link_type: 'sec')

      expect(&create_public_company).not_to change { ExternalLink.count }
      expect(ExternalLink.last.link_id).to eql cik.to_s
    end

    context 'removing a public company\'s sec_cik' do
      it 'removes the external link' do
        expect(&create_public_company).to change { ExternalLink.count }.by(1)

        expect { entity.public_company.update!(sec_cik: nil) }
          .to change { ExternalLink.count }.by(-1)
      end
    end

    context 'no cik listed' do
      let(:create_public_company) do
        proc { entity.add_extension('PublicCompany') }
      end

      it 'does not create a new External Link' do
        expect(&create_public_company).not_to change { ExternalLink.count }
      end
    end
  end
end
