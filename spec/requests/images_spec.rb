describe 'Images' do
  before { login_as(user, scope: :user) }

  after { logout(:user) }

  let(:entity) { create(:entity_person) }
  let(:image) { create(:image, entity: entity) }
  let(:justification) { Faker::Lorem.sentence }

  let(:user) { create_editor }

  describe 'updating an image caption' do
    let(:caption) { Faker::Lorem.sentence(word_count: 3) }
    let(:new_caption) { Faker::Lorem.sentence(word_count: 4) }
    let(:image) { create(:image, entity: entity, caption: caption) }

    it 'updates caption' do
      expect { post "/images/#{image.id}/update", params: { image: { caption: new_caption } } }
        .to change { image.reload.caption }
              .from(caption).to(new_caption)

      expect(response).to have_http_status(302)
    end
  end

  describe 'cropping an image' do
    let(:person) { create(:entity_person) }
    let(:image) { create(:image, is_featured: true, entity: person, width: 1200, height: 900) }

    let(:params) do
      {
        'crop' => {
          'type' => 'original',
          'ratio' => 2.0,
          'x' => 100,
          'y' => 100,
          'w' => 300,
          'h' => 125
        }
      }
    end

    let(:crop_request) do
      lambda do
        post "/images/#{image.id}/crop", params: params, as: :json
      end
    end

    before do
      test_image_path = Rails.root.join('spec', 'testdata', '1200x900.png').to_s
      FileUtils.mkdir_p image.image_file('original').pathname.dirname
      FileUtils.cp(test_image_path, image.image_file('original').path)
    end

    it 'returns json with redirect to url' do
      crop_request.call
      expect(response).to have_http_status :created
      expect(json).to eq({ 'url' => entity_images_path(person) })
    end

    it 'replaces images' do
      expect(person.images.count).to eq 1
      expect(person.featured_image).to have_attributes(width: 1200, height: 900)
      crop_request.call
      expect(person.reload.images.count).to eq 1
      expect(Entity.find(person.id).featured_image).to have_attributes(width: 600, height: 250)
    end
  end
end
