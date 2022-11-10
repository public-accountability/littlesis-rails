describe 'Images' do
  before { login_as(user, scope: :user) }

  after { logout(:user) }

  let(:entity) { create(:entity_person) }
  let(:image) { create(:image, entity: entity) }
  let(:justification) { Faker::Lorem.sentence }

  let(:image_deletion_request) do
    create(:image_deletion_request, image: image, user: create_basic_user)
  end

  context 'with a basic user' do
    let(:user) { create_basic_user }

    describe 'requesting an image to be deleted' do
      let(:deletion_request) do
        proc do
          post(
            '/deletion_requests/images',
            params: { image_id: image.id, justification: justification, entity_id: entity.id.to_s }
          )
        end
      end

      it 'creates an image deletion request' do
        expect(&deletion_request).to change(ImageDeletionRequest, :count).by(1)
        image_deletion_request = ImageDeletionRequest.last

        expect(image_deletion_request.source_id).to eq image.id
        expect(image_deletion_request.user).to eq user
        expect(image_deletion_request.entity_id).to eq entity.id
        expect(response.status).to eq 302
      end
    end

    it 'cannot view deletion requests' do
      get "/deletion_requests/images/#{image_deletion_request.id}"
      expect(response).to have_http_status :forbidden
    end

    it 'cannot approve deletion requests' do
      post(
        "/deletion_requests/images/#{image_deletion_request.id}/review",
        params: { decision: :approved }
      )
      expect(response).to have_http_status :forbidden
    end

    it 'cannot deny deletion requests' do
      post(
        "/deletion_requests/images/#{image_deletion_request.id}/review",
        params: { decision: :denied }
      )
      expect(response).to have_http_status :forbidden
    end
  end

  context 'with an admin account' do
    let(:user) { create_admin_user }

    context 'with an approval request' do
      let(:req) do
        post(
          "/deletion_requests/images/#{image_deletion_request.id}/review",
          params: { decision: :approved }
        )
      end

      it 'approves the deletion' do
        expect { req }.to change { image_deletion_request.reload.status }
          .from('pending').to('approved')

        expect(Image.unscoped.find(image_deletion_request.source_id).is_deleted).to be true
      end
    end

    context 'with a denial request' do
      let(:req) do
        post(
          "/deletion_requests/images/#{image_deletion_request.id}/review",
          params: { decision: :denied }
        )
      end

      it 'denies the deletion' do
        expect { req }.to change { image_deletion_request.reload.status }
          .from('pending').to('denied')

        expect(Image.unscoped.find(image_deletion_request.source_id).is_deleted).to be false
      end
    end
  end
end
