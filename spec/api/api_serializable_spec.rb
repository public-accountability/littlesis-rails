describe 'Api::Serializable', type: :model do
  FAKE_ATTRIBUTES = { 'api' => 'attributes' }

  class TestApiModel < RspecHelpers::TestActiveRecord
    include Api::Serializable

    def api_attributes(options = {})
      FAKE_ATTRIBUTES
    end
  end

  describe 'Api.as_api_json' do
    let(:mock_api_data) { [{ a: 1 }, { b: 2 }] }
    let(:models) do
      Array.new(2) do |n|
        TestApiModel.new.tap do |model|
          expect(model).to receive(:api_data).once.and_return(mock_api_data[n])
        end
      end
    end

    it 'returns api json for an array of models' do
      expect(Api.as_api_json(models))
        .to eql('data' => mock_api_data, 'meta' => Api::META)
    end

    it 'can exclude META information' do
      expect(Api.as_api_json(models, meta: false))
        .to eql('data' => mock_api_data)
    end
  end

  describe 'class methods' do
    subject { TestApiModel }

    let(:ids) { [1, 2] }
    let(:mock_api_data) { { a: 1, b: 3 } }
    let(:mock_model) do
      TestApiModel.new.tap { |m| expect(m).to receive(:api_data).once.and_return(mock_api_data) }
    end

    describe '#as_api_json' do
      it 'returns json response with array of data' do
        expect(subject).to receive(:find).with(ids).and_return([mock_model])
        expect(subject.as_api_json(ids)).to eql('meta' => Api::META, 'data' => [mock_api_data])
      end

      it 'can exclude meata' do
        expect(subject).to receive(:find).with(ids).and_return([mock_model])
        expect(subject.as_api_json(ids, meta: false)).to eql('data' => [mock_api_data])
      end
    end
  end

  describe 'instance methods' do
    subject { TestApiModel.new }

    describe '#api_data' do
      specify do
        expect(subject.api_data)
          .to eql({
                    'type' => 'test-api-models',
                    'id' => subject.id,
                    'attributes' => FAKE_ATTRIBUTES
                  })
      end
    end

    describe 'api_json' do
      let(:model_url) { 'https://littlesis.org/testapimodel/1' }
      before  { expect(subject).to receive(:api_links).and_return({ 'links' => { 'self' => model_url} }) }

      context 'without included' do
        specify do
          expect(subject.api_json)
            .to eql({
                      'data' => {
                        'type' => 'test-api-models',
                        'id' => subject.id,
                        'attributes' => FAKE_ATTRIBUTES,
                        'links' => {
                          'self' => model_url
                        }
                      }
                    })
        end
      end

      context 'with included' do
        let(:included) { ['more data'] }
        before { expect(subject).to receive(:api_included).twice.and_return(included) }
        specify { expect(subject.api_json['included']).to eql included }
      end
    end
  end

  describe 'relationship.api_data' do
    let(:relationship) { build(:relationship) }

    it 'has included field with entity data' do
      expect(relationship.api_json.fetch('included'))
        .to eql [ relationship.entity.api_data(exclude: :extensions), relationship.related.api_data(exclude: :extensions) ]
    end
  end
end
