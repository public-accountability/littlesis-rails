require 'rails_helper'

describe 'Images' do
  let(:entity) { create(:entity_person) }
  let(:user) { create_basic_user }
  before { login_as(user, :scope => :user) }
  after { logout(:user) }

  feature 'Adding an image to a entity: file upload' do
    let(:image_title) { Faker::Dog.meme_phrase }

    before { visit new_image_entity_path(entity) }

    scenario 'Uploading an image from a file' do
      successfully_visits_page new_image_entity_path(entity)

      attach_file 'image_file', Rails.root.join('spec', 'testdata', 'example.png')
      fill_in 'image_title', with: image_title
      check 'image_is_featured'

      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eql 1
      expect(images.first.title).to eql image_title
      expect(images.first.is_featured).to be true

      successfully_visits_page images_entity_path(entity)
    end

  end

  feature 'uploading an image from an url'
end
