describe 'Api::Serializable', type: :model do
  FAKE_ATTRIBUTES = { 'api' => 'attributes' }

  def test_api_class
    Class.new(RspecHelpers::TestActiveRecord) do
      include Api::Serializable

      def self.name
        'test_api_model'
      end

      def api_attributes(**options)
        FAKE_ATTRIBUTES
      end
    end
  end

  describe 'Api.as_api_json' do
    let(:mock_api_data) { [{ a: 1 }, { b: 2 }] }
    let(:models) do
      Array.new(2) do |n|
        test_api_class.new.tap do |model|
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
    let(:ids) { [1, 2] }
    let(:mock_api_data) { { a: 1, b: 3 } }
    let(:mock_model) do
      test_api_class.new.tap { |m| expect(m).to receive(:api_data).once.and_return(mock_api_data) }
    end

    describe '#as_api_json' do
      it 'returns json response with array of data' do
        klass = test_api_class
        expect(klass).to receive(:find).with(ids).and_return([mock_model])
        expect(klass.as_api_json(ids)).to eql('meta' => Api::META, 'data' => [mock_api_data])
      end

      it 'can exclude meata' do
        klass = test_api_class
        expect(klass).to receive(:find).with(ids).and_return([mock_model])
        expect(klass.as_api_json(ids, meta: false)).to eql('data' => [mock_api_data])
      end
    end
  end

  describe 'instance methods' do
    describe '#api_data' do
      specify do
        model = test_api_class.new

        expect(model.api_data).to eq('type' => 'test-api-models',
                                     'id' => model.id,
                                     'attributes' => FAKE_ATTRIBUTES)
      end
    end

    describe 'api_json' do
      let(:model_url) { 'https://littlesis.org/testapimodel/1' }
      let(:mock_model) { test_api_class.new }

      it 'returns json' do
        expect(mock_model).to receive(:api_links).and_return({ 'links' => { 'self' => model_url } })
        expect(mock_model.api_json)
          .to eq({ 'data' => {
                     'type' => 'test-api-models',
                     'id' => mock_model.id,
                     'attributes' => FAKE_ATTRIBUTES,
                     'links' => { 'self' => model_url } }})
      end

      it 'has included information' do
        included_data = ['more data']
        expect(mock_model).to receive(:api_included).twice.and_return(included_data)
        expect(mock_model.api_json['included']).to eq included_data
        expect(mock_model.api_json(skip_included: true)['included']).to be nil
      end
    end
  end

  describe 'relationship.api_data' do
    let(:relationship) { build(:relationship) }

    it 'has included field with entity data' do
      expect(relationship.api_json.fetch('included'))
        .to eq [relationship.entity.api_data(exclude: :extensions), relationship.related.api_data(exclude: :extensions)]
    end
  end
end
