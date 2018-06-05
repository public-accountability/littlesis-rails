# frozen_string_literal: true

module ExternalLinkGroupHelper

  def create_or_update_external_link_test(extension, entity_type)
    describe 'create_or_update_external_link' do
      let(:entity) { create("entity_#{entity_type}") }
      let(:cik) { Faker::Number.unique.number(6) }

      let(:create_entity_extension) do
        proc do
          entity.add_extension(extension.titleize.tr(' ', ''), sec_cik: cik)
        end
      end

      it 'creates a new external link' do
        expect(&create_entity_extension).to change { ExternalLink.count }.by(1)
        expect(ExternalLink.last.link_id).to eql cik.to_s
      end

      it 'updates existing link' do
        ExternalLink.create!(entity: entity,
                             link_id: Faker::Number.unique.number(6),
                             link_type: 'sec')

        expect(&create_entity_extension).not_to change { ExternalLink.count }
        expect(ExternalLink.last.link_id).to eql cik.to_s
      end

      context 'removing an extensions\'s sec_cik' do
        it 'removes the external link' do
          expect(&create_entity_extension).to change { ExternalLink.count }.by(1)

          expect { entity.public_send(extension).update!(sec_cik: nil) }
            .to change { ExternalLink.count }.by(-1)
        end
      end

      context 'no cik listed' do
        let(:create_entity_extension) do
          proc { entity.add_extension(extension.titleize.tr(' ', '')) }
        end

        it 'does not create a new External Link' do
          expect(&create_entity_extension).not_to change { ExternalLink.count }
        end
      end
    end
  end
end
