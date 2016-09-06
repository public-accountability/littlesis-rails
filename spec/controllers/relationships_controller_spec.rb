require 'rails_helper'

RSpec.describe RelationshipsController, type: :controller do

  describe "GET #show" do
    it "returns http success" do
      get :show, {id: 1}
      expect(response).to have_http_status(:success)
    end
  end

end
