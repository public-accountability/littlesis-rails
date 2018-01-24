require "rails_helper"

describe Cmp::CmpOrg do
  describe 'helper methods' do
    describe '#attrs_for' do
      let(:attributes) { { website: 'http://example.com', city: 'new york'} }
      subject { Cmp::CmpOrg.new(attributes) }

      it 'extracts attributes for given model' do
        expect(subject.send(:attrs_for, :entity))
          .to eql(website: 'http://example.com')

        expect(subject.send(:attrs_for, :address))
          .to eql(city: 'new york', latitude: nil, longitude: nil)
      end
    end
  end
end
