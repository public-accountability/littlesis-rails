require 'rails_helper' 

describe 'lists/modifications.html.erb' do
  with_versioning do
    describe 'layout' do
      include ListsHelper
      before do
        l = create(:list)
        l.name = "new name"
        l.save
        l.is_featured = true
        l.save
        inc = create(:entity_org)
        inc_entity = ListEntity.find_or_create_by(list_id: l.id, entity_id: inc.id)
        inc_entity.destroy
        assign(:list, l)
        assign(:versions, Kaminari.paginate_array(List.find(l.id).versions.reverse).page(params[:page]).per(5))
        assign(:all_entities, ListEntity.unscoped.all.where(list_id: l.id).page(params[:page]).per(5))
        render
      end
      
      it 'contains header' do
        expect(rendered).to have_css("#list-header")
      end
      
      it 'contains tabs' do
        expect(rendered).to have_css(".list_tabs")
        expect(rendered).to have_css(".tab")
      end

      it 'contains 2 tables' do
        expect(rendered).to have_css("table", :count => 2)
        expect(rendered).to have_css("thead", :count => 2)
        
      end
      it 'contains 5 <tr> elements' do
        # 3 for each version, 2 for created and deleted entity
        expect(rendered).to have_css("tr", :count => 5)
      end
    end
  end
end
