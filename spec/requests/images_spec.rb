describe Images do
  before { login_as(user, scope: :user) }

  after { logout(:user) }

  let(:entity) { create(:entity_person) }
  let(:image) { create(:image, entity: entity) }
  let(:justification) { Faker::Lorem.sentence }

  let(:image_deletion_request) do
    create(:image_deletion_request, image: image, user: create_really_basic_user)
  end

  context 'as a basic user' do
    let(:user) { create_really_basic_user }

    describe 'requesting an image to be deleted' do
      let(:deletion_request) do
        proc do
          post "/images/#{image.id}/request_deletion",
               params: { 'justification' => justification, 'entity_id' => entity.id.to_s },
               headers: { 'Referer' => 'https://littlesis.org/images' }
        end
      end

      it 'creates an image deletion request' do
        expect(&deletion_request).to change(ImageDeletionRequest, :count).by(1)
        image_deletion_request = ImageDeletionRequest.last

        expect(image_deletion_request.source_id).to eq image.id
        expect(image_deletion_request.user).to eq user
        expect(image_deletion_request.entity_id).to eq entity.id
      end

      it 'redirects backs to refer' do
        deletion_request.call
        expect(response.status).to eq 302
        expect(response.location).to eql 'https://littlesis.org/images'
      end
    end

    it 'cannot view deletion requests' do
      get "/images/deletion_request/#{image_deletion_request.id}"
      expect(response).to have_http_status :forbidden
    end

    it 'cannot approve deletion requests' do
      post "/images/approve_deletion/#{image_deletion_request.id}"
      expect(response).to have_http_status :forbidden
    end

    it 'cannot deny deletion requests' do
      post "/images/deny_deletion/#{image_deletion_request.id}"
      expect(response).to have_http_status :forbidden
    end

    describe 'cropping an image' do
      let(:person) { create(:entity_person) }
      let(:image) { create(:image, is_featured: true, entity: person, width: 1200, height: 900) } 

      let(:params) do
        { 'crop' => {
            'type' => 'original',
            'ratio' => 2.0,
            'x' => 100,
            'y' => 100,
            'w' => 300,
            'h' => 125
          } }
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
        expect(json).to eq({ 'url' => "#{Routes.entity_path(person)}/images" })
      end

      it 'replaces images' do
        entity = Entity.find(person.id)
        expect(entity.images.count).to eq 1
        expect(entity.featured_image.width).to eq 1200
        expect(entity.featured_image.height).to eq 900
        crop_request.call
        expect(entity.reload.images.count).to eq 1
        expect(entity.featured_image.width).to eq 600
        expect(entity.featured_image.height).to eq 250
      end
    end
  end

  context 'as an admin' do
    let(:user) { create_admin_user }

    it 'admins can approve requests' do
      expect { post "/images/approve_deletion/#{image_deletion_request.id}" }
        .to change { image_deletion_request.reload.status }
              .from('pending').to('approved')

      expect(Image.unscoped.find(image_deletion_request.source_id).is_deleted).to be true
    end

    it 'admins can deny requests' do
      expect { post "/images/deny_deletion/#{image_deletion_request.id}" }
        .to change { image_deletion_request.reload.status }
              .from('pending').to('denied')

      expect(Image.unscoped.find(image_deletion_request.source_id).is_deleted).to be false
    end
  end
end
