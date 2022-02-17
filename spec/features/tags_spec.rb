describe 'Tags', :tagging_helper, type: :feature do

  let(:tags) { Array.new(2) { create(:tag) } }
  let(:tag) { tags.first }

  after do
    Tag.remove_instance_variable(:@lookup) if Tag.instance_variable_defined?(:@lookup)
  end

  # setup helpers

  def n_entities (n, subtype = 'Person')
    Array.new(n) { create("entity_#{subtype.downcase}".to_sym) }
  end

  def n_lists (n)
    Array.new(n) { create(:list) }
  end

  def relate(x,y)
    create(:generic_relationship, entity: x, related: y)
  end

  def n_relationships(n)
    Array.new(n) { relate(create(:entity_org), create(:entity_org)) }
  end

  def n_tagables(n, tagable_category)
    send("n_#{tagable_category}".to_sym, n)
  end

  describe "tag index" do
    before do
      tags
      visit "tags/"
    end

    it "has a title" do
      expect(page).to have_selector "#tags-index-title"
    end

    it "has a description" do
      expect(page).to have_selector "#tags-index-description"
    end

    it "links to the tag request form" do
      expect(page.find("#tags-index-description"))
        .to have_link("this form", href: tags_request_path)
    end

    it "shows a list of all tags" do
      expect(page.find("#tags-index-list"))
        .to have_selector ".item", count: tags.size
    end

    it "shows a link to each tag's homepage" do
      tags.each { |tag| expect(page).to have_link(tag.name, href: tag_path(tag)) }
    end

    it "shows a description of each tag" do
      tags.each { |tag| expect(page).to have_text(tag.description) }
    end

    it "sorts tags in alphabetical order" do
      create(:tag, name: "aa")
      refresh_page
      expect(page.all("#tags-index-list .item")[0]).to have_text("aa")
    end
  end

  describe "tag homepage" do

    it 'routing tags by name' do
      create(:tag, name: "foo")
      visit "/tags/foo"
      expect(page).to have_http_status :ok
    end

    describe "tabs" do
      let(:tagable_category) { "" }
      let(:tagables) { [] }

      before  do
        tagables
        visit "/tags/#{tag.id}/#{tagable_category}"
      end

      context "with no tab specified" do
        it "defaults to the entities tab" do
          expect(page).to have_selector("#tag-nav-tab-entities a.active")
        end

        it "shows the tag title and description" do
          expect(page).to have_text tag.name
          expect(page).to have_text tag.description
        end

        it "shows edit tab"
      end

      Tagable.categories.each do |tagable_category|
        context "on #{tagable_category} tab" do
          let(:tagable_category) { tagable_category }

          if tagable_category == Entity.category_sym
            let(:tagables) { n_entities(1, 'Person') + n_entities(1, "Org") }

            context "#{tagable_category} is grouped by subtype" do
              it "shows a tagable list for each subtype" do
                expect(page).to have_selector ".tagable-list", count: 2
              end

              it "shows a subheader for each tag list" do
                expect(page).to have_selector ".tagable-list-subheader", count: 2
              end
            end

          else
            let(:tagables) { n_tagables(1, tagable_category) }
            context "#{tagable_category} is not grouped by type" do

              it "shows one tag list" do
                expect(page).to have_selector ".tagable-list-items", count: 1
              end
              it "does not show a tag list subheader" do
                expect(page).not_to have_selector ".tagable-list-subheader"
              end
            end
          end
        end
      end
    end

    describe "a tagable list" do
      # we use entities here arbitrarily
      let(:tagable_category) { 'entities' }
      let(:tagables) { [] }
      let(:list) { page.all(".tagable-list").first }

      before do
        tagables
        visit "/tags/#{tag.id}/#{tagable_category}"
      end

      context "no tagged items" do
        it "shows an empty list message" do
          expect(page).not_to have_selector '.tagable-list-item'
          expect(page).to have_text "There are no"
        end
      end

      context "less than 20 tagged tagables" do
        let(:tagables) do
          n_tagables(2, tagable_category).map { |t| t.add_tag(tag.id) }
        end

        it "shows the tag title and description" do
          expect(page).to have_text tag.name
          expect(page).to have_text tag.description
        end

        it "shows a list of tagables" do
          expect(list).to have_selector '.tagable-list-item', count: 2
        end

        it "renders the name of each tagable as a link" do
          list.all(".tagable-list-item").each do |item|
            expect(item).to have_link :class => 'tagable-list-item-name'
          end
        end

        it "shows a description of each tagable" do
          list.all(".tagable-list-item").each do |item|
            expect(item).to have_selector ".tagable-list-item-description"
          end
        end

        it "displays last updated date for each tagable" do
          list.all(".tagable-list-item").each do |item|
            sort_text = tagable_category == 'entities' ? 'relationships' : 'ago'
            expect(item.find(".tagable-list-item-sort-info")).to have_text sort_text
          end
        end

        it "truncates descriptions longer than 90 characters" do
          tagables.first.update(blurb: ("a" * 91))
          refresh_page
          expect(page).to have_text("a" * 87 + "...")
        end
      end

      context "more than 20 tagables" do
        let(:tagables) { n_tagables(21, tagable_category).map { |t| t.add_tag(tag.id) } }
        it "only shows 10 entities with pagination bar" do
          expect(page.find("#tagable-lists"))
            .to have_selector '.tagable-list-item', count: 20
        end
      end
    end

    describe 'edits tab' do
      let(:setup) { -> {} }
      before(:each) do
        setup.call
        visit "/tags/#{tag.id}/edits"
      end

      it "has header with active edit tab" do
        expect(page).to have_selector 'li#tag-nav-tab-edits a.active', text: 'Edits'
      end

      it "contains list of edits" do
        expect(page).to have_selector '#tag-homepage-edits-table-container table', count: 1
      end

      describe 'list of edits' do
        let(:person) { create(:entity_person).add_tag(tag.id) }
        let(:list) { create(:list).add_tag(tag.id) }
        let(:relationship) do
          create(:generic_relationship,
                 entity: create(:entity_org),
                 related: create(:entity_org)).add_tag(tag.id)
        end

        context 'a person was recently tagged' do
          let(:setup) { proc { person } }
          edits_table_has_correct_row_count(1)

          it 'contains "tagged" text' do
            expect(page.find('#tag-homepage-edits-table tbody')).to have_text 'tagged'
            expect(page.find('#tag-homepage-edits-table tbody')).not_to have_text 'updated'
          end
        end

        xcontext 'a person was recently updated (and previously tagged)' do
          let(:setup) { proc { person.update_column(:updated_at, Time.current + 1.hour) } }
          edits_table_has_correct_row_count(2)

          it 'contains "tagged" and "updated" text' do
            expect(page.find('#tag-homepage-edits-table tbody')).to have_text 'tagged'
            expect(page.find('#tag-homepage-edits-table tbody')).to have_text 'Entity updated'
          end
        end

        context 'a list and a relationship were recently tagged' do
          let(:setup) { proc { list; relationship; } }

          edits_table_has_correct_row_count(2)

          it 'contains links to the list and relationship' do
            find('#tag-homepage-edits-table tbody') do |el|
              expect(el).to have_link list.name
              expect(el).to have_link relationship.name
            end
          end
        end

        context "tags were added by both system and an analyst" do
          let(:user) { create_basic_user }
          let(:person) { create(:entity_person).add_tag(tag.id, User.system_user_id) }
          let(:list) { create(:list).add_tag(tag.id, user.id) }
          let(:setup) { proc { list; person; } }
          let(:text) { page.all("#tag-homepage-edits-table tbody tr").map(&:text).join(' ') }

          it 'contains two edits' do
            expect(page.all("#tag-homepage-edits-table tbody tr").length).to eql 2
          end

          it "shows `System` next to system edit" do
            expect(text.scan('System').count).to eql 1
          end

          it "shows anaylsist's username next to analyst's edit" do
            expect(text.scan(user.username).count).to eql 1
          end
        end

        xcontext 'a person was tagged, untagged, and then updated' do
          let(:setup) do
            proc {
              person.remove_tag(tag.id)
              person.update_column(:updated_at, Date.tomorrow)
            }
          end

          edits_table_has_correct_row_count(0)
        end

        xcontext 'a list was recently updated' do
          let(:setup) { proc { list.update_column(:updated_at, Date.tomorrow) } }
          edits_table_has_correct_row_count(2)
        end

      end
    end # end describe edits tab
  end # end describe tag homepage
end
