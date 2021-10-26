describe ApplicationHelper, :type => :helper do
  describe 'page_title' do
    it 'generates correct title' do
      expect(helper).to receive(:content_for)
                          .with(:page_title).once.and_return('this is the page title')
      expect(helper.page_title).to eq 'this is the page title - LittleSis'
    end

    it 'sets title to be LittleSis by default' do
      expect(helper).to receive(:content_for).with(:page_title).and_return(nil)
      expect(helper.page_title).to eq 'LittleSis'
    end

    it 'skips the LittleSis suffix if it already contains LittleSis ' do
      expect(helper).to receive(:content_for)
                          .with(:page_title).once.and_return('LittleSis - this is the page title')
      expect(helper.page_title).to eq 'LittleSis - this is the page title'
    end
  end

  describe 'yes_or_no' do
    it 'turns boolean into yes or no' do
      expect(helper.yes_or_no(true)).to eq 'yes'
      expect(helper.yes_or_no(false)).to eq 'no'
    end
  end

  describe 'references_select' do
    let(:references) { Array.new(2) { build(:reference) } }
    let(:selected_id) { nil }
    subject { helper.references_select(references, selected_id) }

    context 'with no selected_id' do
      it { is_expected.to have_css 'option', count: 3 }
      it { is_expected.to have_css 'select.selectpicker' }
      it do
        is_expected.to have_css "option[value='#{references.first.id}']",
                                text: references.first.document.name
      end
      it do
        is_expected.to have_css "option[value='#{references.second.id}']",
                                text: references.second.document.name
      end
      it { is_expected.not_to include 'selected' }
    end

    context 'with a selected_id' do
      let(:selected_id) { references.first.id }
      it { is_expected.to have_css "option[value='#{references.first.id}'][selected='selected']" }
      it { is_expected.to have_css "option[value='#{references.second.id}']" }
    end
  end

  describe 'show_donation_banner?' do
    subject { helper.show_donation_banner? }

    let(:controller_name) { 'lists' }
    let(:action_name) { 'index' }
    let(:donation_banner_display) { nil }

    before do
      allow(helper).to receive(:controller_name).and_return(controller_name)
      allow(controller).to receive(:action_name).and_return(action_name)
      Rails.application.config.littlesis[:donation_banner_display] = donation_banner_display
    end

    context 'when set to everywhere' do
      let(:donation_banner_display) { 'everywhere' }

      it { is_expected.to be true }
    end

    context 'when set to homepage and viewing list page' do
      let(:donation_banner_display) { 'homepage' }

      it { is_expected.to be false }
    end

    context 'when set to homepage and viewing homepage' do
      let(:controller_name) { 'home' }
      let(:donation_banner_display) { 'homepage' }

      it { is_expected.to be true }
    end

    context 'when set to false and viewing homepage' do
      let(:controller_name) { 'home' }
      let(:donation_banner_display) { false }

      it { is_expected.to be false }
    end
  end

  describe 'dashboard_panel' do
    context 'with defaults' do
      subject { helper.dashboard_panel { content_tag('span', 'test') } }

      it { is_expected.to include 'class="card"' }
      it { is_expected.to include 'class="card-header"' }
      it { is_expected.to include 'class="card-body"' }
      it { is_expected.to include 'style="background-color: rgba(0, 0, 0, 0.03)"' }
    end

    context 'with heading' do
      subject { helper.dashboard_panel(heading: 'important message') { content_tag('span', 'test') } }

      it { is_expected.to include 'important message' }
    end

    context 'with color' do
      subject { helper.dashboard_panel(heading: 'important message', color: '#fbb4ae') { content_tag('span', 'test') } }

      it { is_expected.to include 'important message' }
      it { is_expected.to include 'style="background-color: #fbb4ae"' }
    end
  end
end
