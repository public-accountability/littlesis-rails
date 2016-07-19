require 'rails_helper'

describe EntitiesController, type: :controller do
  
  describe '/entities/id' do
    
    before do 
      entity = create(:mega_corp_inc)
      get(:show, {id: entity.id})
    end
    
    it 'renders show template' do
      expect(response).to render_template(:show) 
    end

  end
  
end
