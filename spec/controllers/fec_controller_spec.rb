describe FECController, type: :controller do
  describe 'routes' do

    it do
      is_expected.to route(:get, '/fec/entities/123/contributions').to(action: :contributions, id: 123)
    end

    it do
      is_expected.to route(:get, '/fec/entities/123/match_contributions').to(action: :match_contributions, id: 123)
    end

    it do
      is_expected.to route(:post, '/fec/entities/123/donor_match').to(action: :donor_match, id: 123)
    end

    it do
      is_expected.to route(:delete, '/fec/contribution_unmatch').to(action: :contribution_unmatch)
    end
  end
end
