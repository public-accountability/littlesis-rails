require 'rails_helper'

describe ListEntity do  

  describe 'soft delete' do
    it 'changes the list\'s updated at field after being deleted' do
      list = create(:list)
      corp = create(:mega_corp_inc)
      le = ListEntity.create!(list_id: list.id, entity_id: corp.id)
      list.update_column(:updated_at, 1.day.ago)
      expect { le.soft_delete }.to change { list.reload.updated_at }
    end
  end

end
