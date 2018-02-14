require 'rails_helper'

describe 'lists/modifications.html.erb' do
  with_versioning do
    describe 'layout' do
      include ListsHelper
      let(:list) { create(:list) }
      let(:org) { create(:entity_org) }

      before do
        list.update!(name: "new name")
        list.update!(is_featured: true)
        list_entity = ListEntity.find_or_create_by(list_id: list.id, entity_id: org.id)
        list_entity.destroy
        assign(:list, list)
        assign(:versions, Kaminari
                            .paginate_array(List.find(list.id).versions.reverse)
                            .page(params[:page]).per(5))

        assign(:all_entities, ListEntity
                                .unscoped.all
                                .where(list_id: list.id)
                                .page(params[:page]).per(5))
        render
      end

      it 'contains the header' do
        expect(rendered).to have_css("#list-header")
      end

      it 'contains tabs' do
        expect(rendered).to have_css "#list-tab-menu"
        expect(rendered).to have_css ".tab", text: 'Sources'
      end

      it 'contains 2 tables' do
        expect(rendered).to have_css "table", :count => 2
        expect(rendered).to have_css "thead", :count => 2
      end

      it 'contains 5 <tr> elements' do
        # 3 for each version, 2 for created and deleted entity
        expect(rendered).to have_css "tr", :count => 5
      end
    end
  end
end
