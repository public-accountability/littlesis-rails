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
        expect(NewsletterSignupJob).to receive(:perform_later).with(email).once
      end

      context 'without referer header' do
        before { post '/home/pai_signup', params: { 'email' => email } }

        specify { redirects_to_path('https://news.littlesis.org') }
      end

      context 'with referer header' do
        before do
          post '/home/pai_signup', params: { 'email' => email }, headers: { 'referer' => 'http://example.com' }
        end

        specify { redirects_to_path('http://example.com') }
      end
    end
  end
end
