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

    describe 'pagination' do
      let(:person) { create(:entity_person) }

      # add two versions
      before do
        %w[MediaPersonality PublicIntellectual].each { |ext| person.add_extension ext }
      end

      context 'version count is under default per page limit' do
        subject { EntityHistory.new(person).versions.total_count }
        it { is_expected.to eql 3 }
      end

      context 'has 2 pages of results' do
        context 'requesting page 1' do
          subject { EntityHistory.new(person).versions(per_page: 2, page: 1) }
          specify { expect(subject.count).to eql 2 }
          specify { expect(subject.total_count).to eql 3 }
        end

        context 'requesting page 2' do
          subject { EntityHistory.new(person).versions(per_page: 2, page: 2) }
          specify { expect(subject.count).to eql 1 }
          specify { expect(subject.total_count).to eql 3 }
        end
      end
    end
  end
end
