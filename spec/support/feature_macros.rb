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

  def redirects_to_login_page
    it 'redirects to /login' do
      expect(page.current_path).to eql '/login'
    end
  end
end

# for use in examples
module FeatureExampleMacros
  include FeatureSharedMacros

  def successfully_visits_page(path)
    expect(page.status_code).to eq 200
    expect(page).to have_current_path path
  end

  def page_has_selectors(*selectors)
    selectors.each { |s| page_has_selector s }
  end

  def page_has_selector(*args)
    expect(page).to have_selector(*args)
  end

  def subject_has_selectors(*selectors)
    selectors.each { |s| subject_has_selector s }
  end

  def subject_has_selector(*args)
    expect(subject).to have_selector(*args)
  end
end
