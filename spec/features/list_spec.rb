describe 'list index page', type: :feature do
  before do
    list1 = create(:list)
    list2 = create(:list, name: 'my interesting list')
    entity = create(:entity_org)
    ListEntity.find_or_create_by(list_id: list1.id, entity_id: entity.id)
    ListEntity.find_or_create_by(list_id: list2.id, entity_id: entity.id)
  end

  specify do
    visit '/lists'
    page_has_selector '.alert-info'
    page_has_selector 'input#list-search'
    page_has_selector '.lists_table_name', count: 2
  end
end

describe 'list page', type: :feature do
  let(:document_attributes) { attributes_for(:document) }
  let!(:list) do
    list = create(:list, created_at: Time.current)
    ListEntity.create!(list_id: list.id, entity_id: create(:entity_person).id)
    list.add_reference(document_attributes)
    list
  end
  let!(:earlier_list) do
    list = create(:list, created_at: 1.year.ago)
    ListEntity.create!(list_id: list.id, entity_id: create(:entity_person).id)
    list.add_reference(document_attributes)
    list
  end

  scenario 'visiting the list page' do
    visit list_path(list)
    successfully_visits_page(list_path(List.first) + '/members')
    expect(page.find('#list-name')).to have_text list.name
    expect(page).not_to have_selector '#list-tags-container'
  end

  scenario 'navigating to the sources tab' do
    visit list_path(list)
    click_on 'Sources'
    successfully_visits_page(list_path(List.first) + '/references')
    page_has_selector '#list-sources'
    expect(page).to have_link document_attributes[:name], href: document_attributes[:url]
  end

  feature 'list page with tags' do
    let(:tag) { create(:tag) }
    let!(:tags) { list.add_tag(tag.id) }

    scenario 'tags are visable on the page' do
      visit list_path(list)
      expect(page).to have_selector '#list-tags-container'
      expect(page).to have_selector '#tags-list li', text: tag.name
    end
  end

  scenario 'sorting lists by date/time created' do
    visit lists_path

    find('#lists th .created_at.sorting').click
    expect(page).to have_current_path(lists_path(sort_by: :created_at, order: :desc))
    within "#lists" do
      expect(first("tbody tr")[:id]).to eq("list_#{list.id}")
    end

    find('#lists th .created_at.sorting').click
    expect(page).to have_current_path(lists_path(sort_by: :created_at, order: :asc))
    within "#lists" do
      expect(first("tbody tr")[:id]).to eq("list_#{earlier_list.id}")
    end
  end

  feature 'viewing modifications to a list' do
    let(:user) { create_basic_user }
    before(:each) { login_as(user, scope: :user) }
    after(:each) { logout(:user) }

    with_versioning do
      before do
        PaperTrail.request(whodunnit: user.id.to_s) { @list = create(:list) }
      end

      scenario 'list has been created' do
        visit "#{list_path(List.last)}/modifications"

        page_has_selectors '#list-header', '#list-tab-menu'
        page_has_selector '.tab', text: 'Sources'

        page_has_selector '#record-history-container'
        page_has_selector '#record-history-container table tr', count: 1
        expect(page).to have_text "#{user.username} created the list"
      end

      context 'adding an entity to the list' do
        before do
          PaperTrail.request(whodunnit: user.id.to_s) do
            ListEntity.create!(list: @list, entity: create(:entity_org))
          end
        end

        scenario 'shows both edits' do
          visit "#{list_path(List.last)}/modifications"
          page_has_selector '#record-history-container table tr', count: 2
        end
      end
    end
  end
end
