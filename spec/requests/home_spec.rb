require 'rails_helper'

describe 'Home requests' do
  describe 'adding a new email to the pai newsletter' do
    let(:email) { Faker::Internet.email }

    context 'stupid bot request' do
      before do
        expect(NewsletterSignupJob).not_to receive(:perform_later)
        post '/home/pai_signup', params: { 'email' => email, 'very_important_wink_wink' => 'xyz' }
      end
      denies_access
    end

    context 'valid requests' do
      context 'newsletter signup' do
        before do
          expect(NewsletterSignupJob).to receive(:perform_later).with(email, 'pai').once
        end

        context 'no referer' do
          before { post '/home/pai_signup', params: { 'email' => email } }
          specify { redirects_to_path('https://news.littlesis.org') }
        end

        context 'with referer' do
          before { post '/home/pai_signup', params: { 'email' => email }, headers: { 'referer': 'http://example.com' } }
          specify { redirects_to_path('http://example.com') }
        end
      end

      context 'press list signup' do
        specify do
          expect(NewsletterSignupJob).to receive(:perform_later).with(email, 'press').once
          post '/home/pai_signup/press', params: { 'email' => email }
          redirects_to_path('https://news.littlesis.org')
        end
      end
    end
  end
end
