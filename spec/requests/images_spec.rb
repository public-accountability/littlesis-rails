require 'rails_helper'

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
