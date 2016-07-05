require 'rails_helper'

RSpec.describe ListsController, type: :controller do

  describe '/lists' do

    before do
      @new_list = create(:list)
      @new_list_2 = create(:list, name: 'my interesting list')
      @inc = create(:mega_corp_inc)
      ListEntity.find_or_create_by(list_id: @new_list.id, entity_id: @inc.id)
      ListEntity.find_or_create_by(list_id: @new_list_2.id, entity_id: @inc.id)
      get :index
    end
    
    describe "GET #index" do
      it 'renders the index template' do
        expect(response).to render_template(:index)
        expect(response).to be_success
      end

      it '@lists has correct names' do
        expect(assigns(:lists).length).to eq(2)
        expect(assigns(:lists)[0].name).to eq("Fortune 1000 Companies")
        expect(assigns(:lists)[1].name).to eq("my interesting list")
      end
    end
  end

  describe '/lists/new' do

  end
end
