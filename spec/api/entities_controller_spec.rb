require 'rails_helper'

describe Api::EntitiesController, type: :controller do
  describe 'show' do
    before(:all) do
      DatabaseCleaner.start
      @user = create_basic_user
      @token = ApiToken.create!(user_id: @user.id).token
    end

    after(:all) { DatabaseCleaner.clean }
    
    before(:each) { request.headers['Littlesis-Api-Token'] = @token }

    context 'good request' do
      ATTRIBUTE_KEYS = %w(name blurb summary website parent_id primary_ext updated_at start_date end_date link_count)
      let(:pac) { create(:pac) }

      before(:each) do
        get :show, id: pac.id
        @json = JSON.parse(response.body)
      end

      it { should respond_with(200) }

      it 'is json' do
        expect(response.content_type).to eql 'application/json'
      end

      it 'has meta info' do
        ['copyright', 'license', 'apiVersion'].each do |k|
          expect(@json['meta'].key?(k)).to be true
        end
      end

      it 'sets type to be entities' do
        expect(@json['data']['type']).to eql 'entities'
      end

      it 'sets correct id' do
        expect(@json['data']['id']).to eql pac.id
      end

      it 'has correct attribute keys' do
        ATTRIBUTE_KEYS.each { |k|expect(@json['data']['attributes'].key?(k)).to be true }
        expect(@json['data']['attributes']['name']).to eql 'PAC'
        expect(@json['data']['attributes']['primary_ext']).to eql 'Org'
      end

      it 'has url link' do
        expect(@json['data']['links'].key?('self')).to be true
      end

      it 'does not include extensions information' do
        expect(@json['data']['attributes'].key?('extensions')).to be false
      end
    end

    context 'record not found' do
      before { get :show, id: 100000000 }
      it { should respond_with(404) }
    end

    context 'record deleted' do
      before do
        @deleted_pac = create(:pac, is_deleted: true)
        get :show, id: @deleted_pac
      end
      it { should respond_with(410) }
    end

    context 'request details' do
      before(:each) do
        person = create(:entity_person, name: 'business person')
        person.add_extension('BusinessPerson', sec_cik: 12345)
        get :show, { id: person.id, details: 'TRUE' }
        @json = JSON.parse(response.body)
      end

      it { should respond_with(200) }

      it 'is json' do
        expect(response.content_type).to eql 'application/json'
      end

      it 'includes extensions' do
        expect(@json['data']['attributes'].key?('extensions')).to be true
      end

      it 'includes Person and BusinessPerson info' do
        expect(@json['data']['attributes']['extensions'].key?('Person')).to be true
        expect(@json['data']['attributes']['extensions'].key?('BusinessPerson')).to be true
      end

      it 'has correct sec_cik in response' do
        expect(@json['data']['attributes']['extensions']['BusinessPerson']['sec_cik']).to eql 12345
      end
    end
  end # end show

  describe '/entities/:id/extensions' do
    before(:all) do
      DatabaseCleaner.start
      @user = create_basic_user
      @token = ApiToken.create!(user_id: @user.id).token
      @entity = create(:entity_org)
      @entity.add_extension('PoliticalFundraising')
    end

    after(:all) { DatabaseCleaner.clean }

    before(:each) do
      request.headers['Littlesis-Api-Token'] = @token
      get :extensions, id: @entity.id
      @json = JSON.parse(response.body)
    end

    it { should respond_with(200) }

    it 'data and meta keys' do
      expect(@json.key?('meta')).to be true
      expect(@json.key?('data')).to be true
    end

    it 'returns extension definitions in data as array' do
      expect(@json['data']).to be_a Array
      expect(@json['data'].length). to eql 2
    end
  end

  describe 'Errors' do
    it 'returns unauthorized if missing Littlesis-Api-Token header' do
      get :show, id: 123
      expect(response).to have_http_status 401
    end

    it 'returns forbidden if you submit an invalid token' do
      request.headers['Littlesis-Api-Token'] = 'OBVIOUSLY_THIS_ISNT_A_REAL_TOKEN'
      get :show, id: 123
      expect(response).to have_http_status 403
    end
  end

  describe 'search' do
    let(:user) { create_really_basic_user }
    let(:token) { ApiToken.create!(user_id: user.id).token } 
    
    before(:each) { request.headers['Littlesis-Api-Token'] = token }
    let(:mock_search) { double(:per => double(:page => [build(:person)])) }

    class TestSphinxResponse < Array
      def is_a?(klass)
        return true if klass == ThinkingSphinx::Search
        false
      end
      def current_page; 1 end
      def total_pages; 2 end
    end

    it 'sets status to be 400 if "q" param is not provided' do
      get :search
      expect(response).to have_http_status 400
    end

    it 'returns 200 for valid query' do
      expect(Entity::Search).to receive(:search).and_return(mock_search)
      get :search, q: 'the name of some entity'
      expect(response).to have_http_status 200
    end

    it 'returns array of entities with correct meta data' do
      entities = TestSphinxResponse.new([build(:org), build(:person)])
      expect(Entity::Search).to receive(:search).with('the name of some entity')
                                 .and_return(double(:per => double(:page => entities)))

      get :search, q: 'the name of some entity'
      json = JSON.parse(response.body)
      expect(json['data']).to be_a Array
      expect(json['data'].length).to eql 2
      expect(json['meta']['currentPage']).to eq 1
      expect(json['meta']['pageCount']).to eq 2
    end
  end

  describe 'Private Methods' do
    describe 'page_requested' do
      let(:c) { Api::EntitiesController.new }

      it 'returns 1 if params page is missing' do
        allow(c).to receive(:params).and_return({})
        expect(c.send(:page_requested)).to eq 1
      end

      it 'returns int if valid int is provided' do
        allow(c).to receive(:params).and_return({:page => '7'})
        expect(c.send(:page_requested)).to eq 7
      end

      it 'defaults to 1 if invalid integer is provided' do
        allow(c).to receive(:params).and_return({:page => 'i would like page number three please'})
        expect(c.send(:page_requested)).to eq 1
      end
    end
  end
end
