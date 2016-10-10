require 'rails_helper'

describe NyFilerEntity, type: :model do
  before(:all) do 
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end
  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  describe "associations" do 
    before(:all) do 
      @elected = create(:elected)
      @ny_filer = create(:ny_filer, filer_id: 'A1')
      @filer_entity = NyFilerEntity.create!(entity: @elected, ny_filer: @ny_filer)
    end
    it "belongs to entity" do 
      expect(@filer_entity.entity).to eql @elected
      expect(@elected.ny_filers.length).to eql 1
      expect(@elected.ny_filers[0].id).to eq @filer_entity.id
    end

    it "belongs to ny_filer" do 
      expect(@filer_entity.ny_filer).to eql @ny_filer
      expect(@ny_filer.entities.length).to eql 1
      expect(@ny_filer.ny_filer_entities.length).to eql 1
      expect(@ny_filer.entities[0].id).to eql @elected.id
      expect(@ny_filer.ny_filer_entities[0].id).to eql @filer_entity.id
    end

  end
  
end
