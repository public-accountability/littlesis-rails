describe 'contact/index', type: :view do
  context 'when user signed in' do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
      assign(:contact, ContactForm.new(email: 'email@email.com'))
      render
    end

    it 'has email readonly email tag' do
      css 'input[type=email][readonly][value="email@email.com"]', count: 1
    end

    it 'does not have math captcha_answer' do
      not_css '#contact_form_math_captcha_answer'
    end
  end

  context 'when user not signed in' do
    before do
      assign(:contact, ContactForm.new)
      render
    end

    it 'has title' do
      css 'h1'
    end

    it 'has email tag' do
      css 'input[type=email]', count: 1
      css 'input[type=email][readonly]', count: 0
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
      css 'textarea#contact_form_message', count: 1
    end

    it 'has hcaptcha' do
      css '.h-captcha'
    end
  end
end
