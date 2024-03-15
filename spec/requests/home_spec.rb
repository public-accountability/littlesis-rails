describe 'Home requests' do
  describe 'adding a new emails Action Network' do
    let(:email) { Faker::Internet.email }

    describe 'stupid bot request' do
      before do
        expect(NewsletterSignupJob).not_to receive(:perform_later)
        post '/home/pai_signup', params: { 'email' => email, 'very_important_wink_wink' => 'xyz' }
      end

      denies_access
    end

    describe 'newsletter signup' do
      before do
        expect(NewsletterSignupJob).to receive(:perform_later).with(email, [:signup]).once
      end

      context 'without referer header' do
        before { post '/home/pai_signup', params: { 'email' => email } }

        specify { redirects_to_path('https://news.littlesis.org') }
      end
    end
  end

  describe 'page redirects' do
    specify do
      get "/about"
      expect(response).to redirect_to("/database/about")
    end

    specify do
      get "/bulk_data"
      expect(response).to redirect_to("/database/bulk_data")
    end
  end
end
