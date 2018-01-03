require "rails_helper"

describe "partial: entities/actions" do
  let(:org) { build(:org, updated_at: 1.day.ago, last_user: build(:sf_user, user: build(:user))) }
  let(:person) { build(:person, updated_at: 1.day.ago, last_user: build(:sf_user, user: build(:user))) }
  let(:entity) { org }

  context 'when user is an advanced user' do
    let(:user) do
      u = build(:user)
      expect(u).to receive(:has_legacy_permission).with('importer').and_return(true)
      expect(u).to receive(:has_legacy_permission).with('bulker').and_return(true)
      allow(u).to receive(:has_legacy_permission).with('admin').and_return(false)
      u
    end

    before do
      expect(view).to receive(:user_signed_in?).and_return(true)
      assign(:entity, entity)
      render partial: 'entities/actions.html.erb', locals: { entity: entity, current_user: user }
    end

    context 'org page' do
      specify { css 'a', text: 'remove' }
      specify { css 'a', text: 'add bulk' }
      specify { not_css 'a', text: 'match donations' }
    end

    context 'person page' do
      let(:entity) { person }
      specify { css 'a', text: 'remove' }
      specify { css 'a', text: 'add bulk' }
      specify { css 'a', text: 'match donations' }
    end
  end

  context 'when user is not signed in' do
    before do
      expect(view).to receive(:user_signed_in?).and_return(false)
      assign(:entity, entity)
      render partial: 'entities/actions.html.erb', locals: { entity: entity, current_user: nil }
    end

    specify { css 'a', text: 'add relationship' }
    specify { css 'a', text: 'edit' }
    specify { css 'a', text: 'flag' }
    specify { expect(view).to render_template(:partial => "shared/_entity_history") }
  end
end
