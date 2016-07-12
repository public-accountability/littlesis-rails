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
        assign(:list, l)
        assign(:versions, Kaminari.paginate_array(List.find(l.id).versions.reverse).page(params[:page]).per(5))
        render
      end
      
      it 'contains header' do
        expect(rendered).to have_css("#list-header")
      end
      
      it 'contains tabs' do
        expect(rendered).to have_css(".list_tabs")
        expect(rendered).to have_css(".tab")
      end

      it 'contains table' do
        expect(rendered).to have_css("table")
        expect(rendered).to have_css("thead")
        expect(rendered).to have_css("tr", :count => 3)
      end
    end
  end
end
