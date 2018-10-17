require 'rails_helper'

# rubocop:disable RSpec/VerifiedDoubles, RSpec/ExpectInHook, RSpec/NamedSubject

describe EntityLastEditorPresenter do
  subject { EntityLastEditorPresenter.new(person) }

  let(:person_time) { Time.current }
  let(:version_time) { Time.current }
  let(:user1) { build(:user_with_id) }
  let(:user2) { build(:user_with_id) }

  let(:version) do
    build(:entity_version, created_at: version_time, whodunnit: user1.id.to_s)
  end

  let(:person) do
    build(:person, updated_at: person_time, last_user_id: user2.sf_guard_user_id)
  end

  before do
    allow(person).to receive(:last_user).and_return(double(user: user2))
    allow(person).to receive(:versions)
                       .and_return(double(reorder:
                                            double(limit:
                                                     double(:[] => version))))
  end

  context 'when version is lastest edit' do
    let(:person_time) { 1.hour.ago }

    before do
      expect(User).to receive(:find_by).with(id: user1.id.to_s).and_return(user1)
    end

    specify { expect(subject.last_editor).to eq user1 }
    specify { expect(subject.last_edited_at.change(usec: 0)).to eq version_time.change(usec: 0) }

    describe 'last_edited_link' do
      subject { EntityLastEditorPresenter.new(person).html }

      let(:html) do
        <<-HTML
<div id="entity-edited-history">Edited by<strong>
<a href="/users/#{user1.username}">#{user1.username}</a></strong>
less than a minute ago
<a href="#{Routes.entity_path(person)}/edits">History</a>
</div>
        HTML
      end
      it { is_expected.to eql html.tr("\n", '') }
    end
  end

  context 'when version is the lastest edit, and user is missing' do
    let(:person_time) { 1.hour.ago }

    before do
      expect(User).to receive(:find_by).with(id: user1.id.to_s).and_return(nil)
    end

    specify { expect(subject.last_editor).to eq User.system_user }
  end

  context 'when version is at same time as updated_at' do
    before do
      expect(User).to receive(:find_by).with(id: user1.id.to_s).and_return(user1)
    end

    specify { expect(subject.last_editor).to eq user1 }
    specify { expect(subject.last_edited_at.change(usec: 0)).to eq version_time.change(usec: 0) }
  end

  context 'when updated_at is latest edit' do
    let(:version_time) { 1.hour.ago }

    before { expect(User).not_to receive(:find_by) }

    specify { expect(subject.last_editor).to eq user2 }
    specify { expect(subject.last_edited_at.change(usec: 0)).to eq person_time.change(usec: 0) }
  end
end

# rubocop:enable RSpec/VerifiedDoubles, RSpec/ExpectInHook, RSpec/NamedSubject

