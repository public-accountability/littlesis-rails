describe 'entities/add_relationship' do
  let(:user) { build(:user) }
  let(:entity) { build(:mega_corp_inc, updated_at: Time.current, last_user: user, id: rand(100)) }

  describe 'layout' do
    before do
      assign(:entity, entity)
      render
    end

    specify { css 'h3', :text => "Create a new relationship" }
    specify { css 'button.btn-close' }
    specify { css '#add-relationship-page' }
  end
end
