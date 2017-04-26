require "rails_helper"

describe "partial: entities/actions" do
  context 'when user is not signed in' do
    before do
      expect(view).to receive(:user_signed_in?).and_return(false)
      org = build(:org,
                  updated_at: 1.day.ago,
                  last_user: build(:sf_user, user: build(:user)))
      assign(:entity, org)
      render partial: 'entities/actions.html.erb'
    end

    it 'contains add relationship button' do
      css 'a', text: 'add relationship'
    end

    it 'contains edit button' do
      css 'a', text: 'edit'
    end

    it 'contains flag button' do
      css 'a', text: 'flag'
    end

    it 'renders entity history' do
      expect(view).to render_template(:partial => "shared/_entity_history")
    end
  end
end
