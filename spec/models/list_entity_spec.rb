require 'rails_helper'

describe ListEntity do  


  describe ('creating list entries') do 

    it 'retrieves all List Entities for a list_id' do 
      
      list = create(:list)
      inc = create(:mega_corp_inc)
      llc = create(:mega_corp_llc)
      inc_entity = ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
      ListEntity.find_or_create_by(list_id: list.id, entity_id: llc.id)
      inc_entity.destroy
      expect(ListEntity.where(list_id: list.id).count).to eq (1)
      expect(ListEntity.unscoped.where(list_id: list.id).count).to eq(2)
    end
    
    context 'after destroying a list entity' do 
      it  're-adding the same one creates a new entry' do
        list_entity_count = ListEntity.count
        list = create(:list)
        inc = create(:mega_corp_inc)
        
        le = ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
        expect(ListEntity.count).to eql (list_entity_count + 2)
        expect(ListEntity.unscoped.count).to eql (list_entity_count + 2)
        le.destroy
        expect(ListEntity.count).to eql(list_entity_count + 1)
        expect(ListEntity.unscoped.count).to eql (list_entity_count + 2)
        expect(ListEntity.unscoped.deleted.last).to eql(le)
        le2 = ListEntity.find_or_create_by(list_id: list.id, entity_id: inc.id)
        expect(ListEntity.count).to eql (list_entity_count + 2)
        expect(ListEntity.unscoped.count).to eql (list_entity_count + 3)
        expect(le.id).not_to eq(le2.id)
      end
    end
  end
end
