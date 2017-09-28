module FeatureSharedMacros
  include Routes
  # h/t: https://makandracards.com/makandra/760-reload-the-page-in-your-cucumber-features
  def refresh_page
    visit [current_path, page.driver.request.env['QUERY_STRING']].reject(&:blank?).join('?')
  end
end

# for use in example groups
module FeatureGroupMacros
  include FeatureSharedMacros
  
  def denies_access
    it 'denies access' do
      expect(page.status_code).to eq 403
      expect(page).to have_content 'Bad Credentials'
    end
  end
end

# for use in examples
module FeatureExampleMacros
  include FeatureSharedMacros
end
