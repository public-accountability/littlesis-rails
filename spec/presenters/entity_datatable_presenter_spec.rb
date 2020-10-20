describe EntityDatatablePresenter do
  let(:blurb) { Faker::GreekPhilosophers.quote }
  let(:entity) { create(:entity_org, blurb: blurb) }

  describe 'to_hash' do
    subject { EntityDatatablePresenter.new(entity).to_hash }
    it do
      is_expected.to eql('id' => entity.id,
                         'name'=> entity.name,
                         'blurb' => blurb,
                         'url' => ApplicationController.helpers.concretize_entity_url(entity),
                         'types' => [2])
    end
  end
end
