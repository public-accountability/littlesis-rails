describe "entities/actions" do
  let(:org) do
    build(:org,
          created_at: 1.day.ago,
          updated_at: 1.day.ago,
          last_user: build(:user))
  end
  let(:person) do
    build(:person,
          created_at: 1.day.ago,
          updated_at: 1.day.ago,
          last_user: build(:user))
  end
  let(:entity) { org }

  context 'when user is an advanced user' do
    let(:user) do
      build(:user, abilities: UserAbilities.new(:edit, :bulk))
    end

    before do
      expect(view).to receive(:user_signed_in?).and_return(true)
      assign(:entity, entity)
      render partial: 'entities/actions', locals: { entity: entity, current_user: user }
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
      render partial: 'entities/actions', locals: { entity: entity, current_user: nil }
    end

    specify { css 'a', text: 'add relationship' }
    specify { css 'a', text: 'edit' }
    specify { css 'a', text: 'flag' }
    specify { css '#entity-edited-history' }
  end
end
