require 'rails_helper'

describe RelationshipsController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      rel = build(:relationship)
      expect(Relationship).to receive(:find).with("1").and_return(rel)
      get :show, {id: 1}
      expect(response).to have_http_status(:success)
    end
  end

end
