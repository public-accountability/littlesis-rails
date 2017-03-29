require 'rails_helper'

describe 'home/contact.html.erb', type: :view do
  describe 'user signed in ' do
    before(:each) do
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(double(email: 'email@email.com'))
      render
    end

    it 'does not have email tag' do
      css 'input[type=email]', count: 0
    end

    it 'has email in form' do
      css 'p.form-control-static', text: 'email@email.com'
    end

    it 'has input with email address' do
      expect(rendered).to have_tag('input[type=hidden]', with: { value: 'email@email.com' })
    end
  end

  describe 'layout' do
    before { render }

    it 'has title' do
      css 'h1'
    end

    context 'user not signed in' do
      it 'has email tag' do
        css 'input[type=email]', count: 1
      end
    end

    it 'contains form' do
      css 'form', count: 1
    end

    it 'has select' do
      css 'select', count: 1
    end

    it 'has 7 options' do
      css 'option', count: 7
    end

    it 'has text area' do
      css 'textarea', count: 1
    end
  end
end
