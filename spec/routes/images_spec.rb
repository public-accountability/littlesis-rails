describe 'images routes', type: :routing do
  let(:image) { create(:image, entity: create(:entity_org)) }

  it 'routes /images/ paths to the relevant controller' do
    expect(get: "/images/#{image.id}/crop").to route_to(
      controller: 'images',
      action: 'crop',
      id: image.id.to_s
    )
  end

  it 'defines distinct helpers for images routes' do
    expect(ApplicationController.helpers.ls_image_path('boffin'))
      .to eq '/images/boffin/update'
  end

  it 'does not overwrite image asset routing helpers' do
    expect { ApplicationController.helpers.image_path('boffin') }
      .to raise_error(Sprockets::Rails::Helper::AssetNotFound)
  end
end
