require 'rails_helper'

describe 'Api::Serializer' do
  it 'has MODEL_INFO const with common ignores' do
    expect(Api::Serializer::MODEL_INFO['common']).to be_a Hash
    expect(Api::Serializer::MODEL_INFO['common']['ignore']).to be_a Array
    expect(Api::Serializer::MODEL_INFO['common']['ignore']).to include 'last_user_id'
  end

  describe 'Entity' do
    let(:entity) { build(:corp, last_user_id: 123, id: rand(100)) }
    subject { Api::Serializer.new(entity).attributes }

    context 'removes fields from attributes' do
      ['is_deleted', 'created_at', 'last_user_id', 'merged_id', 'link_count'].each do |x|
        it { is_expected.not_to have_key x }
      end
    end

    context 'keeps other attributes' do
      ["id", "name", "blurb", "summary","website", "parent_id",
       "primary_ext", "updated_at", "start_date", "end_date" ].each do |x|
        it { is_expected.to have_key x }
      end
    end

    context 'additional fields' do
      before(:all) do
        DatabaseCleaner.start
        @corp = create(:entity_org, last_user_id: 1)
        @corp.aliases.create!(name: 'other corp name')
        @corp.add_extension('Business')
      end
      after(:all) { DatabaseCleaner.clean }
      subject { Api::Serializer.new(@corp).attributes }

      context 'with extensions' do
        it { is_expected.to include('types' => ['Organization', 'Business']) }
        it { is_expected.to include('aliases' => ['org', 'other corp name']) }
        it { is_expected.to have_key 'extensions' }
        context 'extensions' do
          subject { Api::Serializer.new(@corp).attributes['extensions'] }
          it { is_expected.to have_key 'Org' }
          it { is_expected.to have_key 'Business' }
        end
      end

      context 'without extensions' do
        subject { Api::Serializer.new(@corp, exclude: :extensions).attributes }
        it { is_expected.not_to have_key 'extensions' }
        it { is_expected.to have_key 'types' }
      end

      context 'without extensions and types' do
        subject { Api::Serializer.new(@corp, exclude: [:extensions, :types]).attributes }
        it { is_expected.not_to have_key 'extensions' }
        it { is_expected.not_to have_key 'types' }
      end
    end
  end # end describe Entity

  describe 'ExtensionRecord' do
    let(:er) { build(:extension_record, id: 1) }
    subject { Api::Serializer.new(er).attributes }
    specify { expect(subject).to eql('id' => 1,
                                     'definition_id' => 2,
                                     'name' => 'Org',
                                     'display_name' => 'Organization') }
  end
end
