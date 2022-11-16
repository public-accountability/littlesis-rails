describe 'Oligrapher' do
  let(:other_user) { create_basic_user }
  let(:user) { create_basic_user }
  let(:admin) { create_admin_user }
  let(:regular_map) { create(:network_map, user_id: user.id) }
  let(:private_map) { create(:network_map, is_private: true, user_id: user.id) }
  let(:featured_map) { create(:network_map, is_featured: true, user_id: user.id) }
  let(:maps) { [regular_map, private_map, featured_map] }

  before { maps }

  describe 'oligrapher creation page' do
    before { login_as(user, scope: :user) }
    after { logout(user) }

    def has_script_src(page, query_string)
      page.all("script").filter { _1['src'].include?(query_string) }.length.positive?
    end

    it 'uses new oligrapher path' do
      visit new_oligrapher_path
      successfully_visits_page new_oligrapher_path
      expect(has_script_src(page, Rails.application.config.littlesis.oligrapher_commit)).to be true
      expect(has_script_src(page, Rails.application.config.littlesis.oligrapher_beta)).to be false
    end

    it 'uses oligrapher beta commit if requested' do
      user.settings.update({ oligrapher_beta: true })
      user.save!
      visit new_oligrapher_path
      successfully_visits_page new_oligrapher_path
      expect(has_script_src(page, Rails.application.config.littlesis.oligrapher_commit)).to be false
      expect(has_script_src(page, Rails.application.config.littlesis.oligrapher_beta)).to be true
    end
  end

  describe 'Anonyomous users can view embedded regular maps' do
    before { visit oligrapher_path(regular_map) }

    specify { successfully_visits_page oligrapher_path(regular_map) }
  end

  describe 'v3 maps use oligrapher_commit' do
    specify do
      map = create(:network_map, user_id: user.id, oligrapher_commit: "42022f34c3dfdefdff91beabdb9445be0066ada7")
      visit oligrapher_path(map)
      successfully_visits_page oligrapher_path(map)
      expect(
        page.all("script").filter { _1['src'].include?("oligrapher-v3.js") }.length.positive?
      ).to be true
    end
  end

  # describe 'v3 maps use v3 assets' do
  #   specify do
  #     map = create(:network_map, user_id: user.id, oligrapher_commit: "42022f34c3dfdefdff91beabdb9445be0066ada7")
  #     visit oligrapher_path(map)
  #     successfully_visits_page oligrapher_path(map)
  #     expect(
  #       page.all("script").filter { _1['src'].include?("oligrapher-42022f34c3dfdefdff91beabdb9445be0066ada7.js") }.length.positive?
  #     ).to be true
  #   end
  # end

  describe 'Users can view their own private maps' do
    before do
      login_as(user, scope: :user)
      visit oligrapher_path(private_map)
    end

    after { logout(user) }

    it 'map page is viewable' do
      successfully_visits_page oligrapher_path(private_map)
    end
  end

  describe 'other users cannot view private maps' do
    before { login_as(other_user, scope: :user) }
    after { logout(other_user) }

    it 'access is denied to map page' do
      visit oligrapher_path(private_map)
      expect(page).to have_http_status :not_found
    end
  end
end
