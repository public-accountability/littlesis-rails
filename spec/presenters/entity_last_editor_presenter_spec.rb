# rubocop:disable RSpec/VerifiedDoubles, RSpec/ExpectInHook, RSpec/NamedSubject

describe EntityLastEditorPresenter do
  subject { EntityLastEditorPresenter.new(person) }

  let(:person_time) { Time.current }
  let(:version_time) { Time.current }
  let(:last_edited_at) { version_time }

  let(:user1) { build(:user_with_id) }
  let(:user2) { build(:user_with_id) }

  let(:person) do
    build(:person, updated_at: person_time, last_user_id: user2.id)
  end

  let(:edited_enity) do
    build(:edited_entity, user: user1, created_at: last_edited_at)
  end

  before do
    allow(person).to receive(:last_user).and_return(double(user: user2))

    allow(EditedEntity).to receive(:order)
                             .with(created_at: :desc)
                             .and_return(double(:find_by => edited_enity))
  end

  context 'when edited entity is lastest edit' do
    let(:person_time) { 1.hour.ago }

    specify { expect(subject.last_editor).to eq user1 }
    specify { expect(subject.last_edited_at.change(usec: 0)).to eq last_edited_at.change(usec: 0) }

    describe 'last_edited_link' do
      let(:html) do
        "<div id=\"entity-edited-history\">Edited by <strong><a href=\"/users/#{user1.username}\">#{user1.username}</a></strong> less than a minute ago <a href=\"#{ApplicationController.helpers.concretize_history_entity_path(person)}\">History</a></div>"
      end

      specify do
        expect(EntityLastEditorPresenter.html(person).to_s).to eq html
      end

      # it { is_expected.to eq html.tr("\n", '') }
    end
  end

  context 'when edited entity is the lastest edit, and user is missing' do
    let(:person_time) { 1.hour.ago }

    let(:edited_enity) do
      build(:edited_entity, user: nil, created_at: last_edited_at)
    end

    specify { expect(subject.last_editor).to eq User.system_user }
  end

  context 'when edited entity is at same time as updated_at' do
    specify { expect(subject.last_editor).to eq user1 }
    specify { expect(subject.last_edited_at.change(usec: 0)).to eq version_time.change(usec: 0) }
  end

  context 'when updated_at is for latest edit' do
    let(:version_time) { 1.hour.ago }
    specify { expect(subject.last_editor).to eq User.system_user }
    specify { expect(subject.last_edited_at.change(usec: 0)).to eq person_time.change(usec: 0) }
  end
end

# rubocop:enable RSpec/VerifiedDoubles, RSpec/ExpectInHook, RSpec/NamedSubject
