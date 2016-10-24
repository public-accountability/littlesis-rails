require 'rails_helper'

describe HomeController, type: :controller do 

  describe 'GET #index' do 
    
    before do 
      expect(Person).to receive(:count).and_return(5)
      expect(Org).to receive(:count).and_return(10)
      get :index
    end
    
    it 'responds with 200' do
      expect(response.status).to eq(200)
    end

    it { should render_template('index') }

    it 'has @dots_connected' do 
      expect(assigns(:dots_connected)).to eql ['1', '5']
    end
    
  end
end
