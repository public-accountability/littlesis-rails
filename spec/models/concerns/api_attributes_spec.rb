require 'rails_helper'

describe 'ApiAttributes', type: :model do
  FAKE_ATTRIBUTES = { 'api' => 'attributes' }

  class TestApiModel < TestActiveRecord
    include ApiAttributes

    def api_attributes(options = {})
      FAKE_ATTRIBUTES
    end
  end

  describe 'class methods' do
    subject { TestApiModel }
    let(:ids) { [1, 2] }
    let(:mock_model) { TestApiModel.new.tap { |m| expect(m).to receive(:api_data).once } }
    let(:mock_api_data) { [{ a: 1 }, { b: 2 }] }

    describe '#api_base' do
      specify { expect(subject.api_base).to eql('meta' => Api::META) }
    end

    describe '#api_data' do
      it 'finds models with given ids and call api_data on each model' do
        expect(subject).to receive(:find).with(ids).and_return([mock_model])
        subject.api_data(ids)
      end
    end

    describe '#as_api_json' do
      it 'returns json response with array of data' do
        expect(subject).to receive(:api_data).with(ids).and_return(mock_api_data)
        expect(subject.as_api_json(ids)).to eql( { 'meta' => Api::META, 'data' => mock_api_data } )
      end
    end
  end

  describe 'instance methods' do
    subject { TestApiModel.new }

    describe '#api_base' do
      specify { expect(subject.api_base).to eql('meta' => Api::META) }
    end

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
      before  { expect(subject).to receive(:api_links).and_return({'self' => model_url}) }

      context 'without included' do
        specify do
          expect(subject.api_json)
            .to eql({
                      'data' => {
                        'type' => 'test-api-models',
                        'id' => subject.id,
                        'attributes' => FAKE_ATTRIBUTES
                      },
                      'links' => {
                        'self' => model_url
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
end
