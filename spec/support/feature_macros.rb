module FeatureMacros
  def denies_access
    it 'denies access' do
      expect(page.status_code).to eq 403
      expect(page).to have_content 'Bad Credentials'
    end
  end
end
