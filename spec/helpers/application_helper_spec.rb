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

    it 'skips the LittleSis suffix if it already contains LittleSis' do
      expect(helper).to receive(:content_for)
                          .with(:page_title).once.and_return('LittleSis - this is the page title')
      expect(helper.page_title).to eq 'LittleSis - this is the page title'
    end
  end

  describe 'references_select' do
    let(:references) { Array.new(2) { build(:reference) } }

    it 'creates selectpicker' do
      html = helper.references_select(references, nil)
      expect(html).to have_css 'option', count: 3
      expect(html).to have_css 'select.selectpicker'
      expect(html).to have_css "option[value='#{references.first.id}']", text: references.first.document.name
      expect(html).to have_css "option[value='#{references.second.id}']", text: references.second.document.name
      expect(html).not_to include 'selected'
    end

    it 'selects reference when provded a selected_id' do
      html = helper.references_select(references, references.first.id)
      expect(html).to have_css "option[value='#{references.first.id}'][selected='selected']"
      expect(html).to have_css "option[value='#{references.second.id}']"
    end
  end

  describe 'show_donation_banner?' do
    it 'when set to "everywhere" it shows on the lists page' do
      Rails.application.config.littlesis[:donation_banner_display] = 'everywhere'
      allow(helper).to receive(:controller_name).and_return('lists')
      allow(controller).to receive(:action_name).and_return('index')
      expect(helper.show_donation_banner?).to be true
    end

    it 'when set to "homepage" it shows it on the homepage' do
      Rails.application.config.littlesis[:donation_banner_display] = 'homepage'
      allow(helper).to receive(:controller_name).and_return('home')
      allow(controller).to receive(:action_name).and_return('index')
      expect(helper.show_donation_banner?).to be true
    end

    it 'when set to "homepage" it hides it from lists page' do
      Rails.application.config.littlesis[:donation_banner_display] = 'homepage'
      allow(helper).to receive(:controller_name).and_return('lists')
      allow(controller).to receive(:action_name).and_return('index')
      expect(helper.show_donation_banner?).to be false
    end

    it 'when set to false it hides it from the homepage' do
      Rails.application.config.littlesis[:donation_banner_display] = false
      allow(helper).to receive(:controller_name).and_return('homepage')
      allow(controller).to receive(:action_name).and_return('index')
      expect(helper.show_donation_banner?).to be false
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

  describe 'bs_row_column' do
    it 'generate form group html' do
      expect(helper.registrations_form_group { 'test' })
        .to eq '<div class="row"><div class="col">test</div></div>'
    end
  end
end
