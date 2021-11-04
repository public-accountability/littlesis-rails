describe FECController, type: :controller do
  describe 'routes' do

    it do
      is_expected.to route(:get, '/fec/entities/123/contributions').to(action: :contributions, id: 123)
    end

    it do
      is_expected.to route(:get, '/fec/entities/123/match_contributions').to(action: :match_contributions, id: 123)
    end

    it do
      is_expected.to route(:post, '/fec/fec_matches').to(action: :create_fec_match)
    end

    it do
      is_expected.to route(:delete, '/fec/fec_matches/123').to(action: :delete_fec_match, id: 123)
    end
  end
end
