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
      assign(:entity, entity)
      render partial: 'entities/actions', locals: { entity: entity, current_user: user }
    end

    describe 'org page' do
      specify { css 'a', text: 'remove' }
      specify { css 'a', text: 'add bulk' }
    end

    describe 'person page' do
      let(:entity) { person }

      specify { css 'a', text: 'remove' }
      specify { css 'a', text: 'add bulk' }
    end
  end
end
