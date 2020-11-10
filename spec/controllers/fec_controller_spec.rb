describe FECController, type: :controller do
  describe 'routes' do

    it do
      is_expected.to route(:get, '/fec/entities/123/donations').to(action: :entity_donations)
    end

    it do
      is_expected.to route(:get, '/fec/entities/123/potential_donations').to(action: :entity_potential_donations)
    end
  end
end
