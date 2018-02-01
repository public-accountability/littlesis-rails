require 'rails_helper'

describe EntityHistory do
  with_versioning do
    subject { EntityHistory.new(entity) }

    describe 'entity internal attribute' do
      let(:entity) { build(:org) }
      specify { expect(subject.send(:entity)).to eql entity }
    end

    describe 'after entity has been created' do
      let!(:entity) { create(:entity_org) }
      subject { EntityHistory.new(entity) }
      specify { expect(subject.versions.length).to eql 1 }
      describe 'version of create event' do
        subject { EntityHistory.new(entity).versions.first }
        specify { expect(subject.event).to eql 'create' }
      end
    end
  end
end
