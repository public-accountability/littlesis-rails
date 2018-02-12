require 'rails_helper'

describe 'EntityVersionPresenter' do
  with_versioning do
    let(:user) { create_really_basic_user }
    let(:entity) { create(:entity_person) }
    let(:entity_history) { EntityHistory.new(entity) }
    let(:versions) do
      entity_history.versions.as_presenters.map(&:render)
    end

    before do
      PaperTrail.whodunnit(user.id.to_s) { entity }
    end

    context 'entity was created' do
      specify do
        version = entity_history.versions.as_presenters.first
        expect(version.render).to include "created the entity"
      end
    end

    context 'extension was created and removed' do
      before do
        entity.add_extension 'Academic'
        entity.remove_extension 'Academic'
      end
      specify do
        expect(versions).to include "System added extension Academic"
      end

      specify do
        expect(versions).to include "System removed extension Academic"
      end
    end

    describe '#user_link' do
      subject { entity_history.versions.as_presenters.first }
      it 'generates link for user' do
        expect(subject.send(:user_link)).to include "href=\"/users/#{user.username}\""
      end
    end
  end
end
