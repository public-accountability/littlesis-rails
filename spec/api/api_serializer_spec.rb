describe 'Api::Serializer' do
  it 'has MODEL_INFO const with common ignores' do
    expect(Api::Serializer::MODEL_INFO['common']).to be_a Hash
    expect(Api::Serializer::MODEL_INFO['common']['ignore']).to be_a Array
    expect(Api::Serializer::MODEL_INFO['common']['ignore']).to include 'last_user_id'
  end

  describe 'Entity' do
    let(:entity) { create(:entity_org, last_user_id: 1) }

    it 'removes fields from attributes' do
      %w[is_deleted created_at last_user_id merged_id link_count].each do |x|
        expect(Api::Serializer.new(entity).attributes).not_to have_key x
      end
    end

    it 'keeps other attributes' do
      %w[id name blurb summary website parent_id primary_ext updated_at start_date end_date].each do |x|
        expect(Api::Serializer.new(entity).attributes).to have_key x
      end
    end

    describe 'additional fields' do
      subject { Api::Serializer.new(corp).attributes }

      let(:corp) { create(:entity_org, last_user_id: 1) }

      before do
        corp.aliases.create!(name: 'other corp name')
        corp.add_extension('Business')
      end

      context 'with extensions' do
        it { is_expected.to include('types' => ['Organization', 'Business']) }
        it { is_expected.to include('aliases' => ['org', 'other corp name']) }
        it { is_expected.to have_key 'extensions' }

        specify do
          extension_attributes = Api::Serializer.new(corp).attributes['extensions']
          expect(extension_attributes).to have_key 'Org'
          expect(extension_attributes).to have_key 'Business'
        end
      end

      context 'without extensions' do
        subject(:attributes) { Api::Serializer.new(corp, exclude: :extensions).attributes }

        specify do
          expect(attributes).not_to have_key 'extensions'
          expect(attributes).to have_key 'types'
        end
      end

      context 'without extensions and types' do
        subject(:attributes) { Api::Serializer.new(corp, exclude: [:extensions, :types]).attributes }

        specify do
          expect(attributes).not_to have_key 'extensions'
          expect(attributes).not_to have_key 'types'
        end
      end
    end
  end

  describe 'ExtensionRecord' do
    let(:er) { build(:extension_record, id: 1) }

    let(:attributes) { Api::Serializer.new(er).attributes }

    specify do
      expect(attributes).to eql('id' => 1,
                                'definition_id' => 2,
                                'name' => 'Org',
                                'display_name' => 'Organization')
    end
  end
end
