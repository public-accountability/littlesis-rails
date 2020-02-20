# frozen_string_literal: true

describe OligrapherConnectionsService do
  it 'sets @entity' do
    entity = build(:org)
    expect(
      OligrapherConnectionsService.new(entity).instance_variable_get(:@entity)
    ).to eq entity
  end

end
