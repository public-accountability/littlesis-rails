require 'rails_helper'

describe 'Images' do
  let(:entity) { create(:entity_person) }
  let(:user) { create_basic_user }

  before { login_as(user, :scope => :user) }

  after { logout(:user) }

  feature 'Adding an image to a entity' do
    let(:image_title) { Faker::Creature::Dog.meme_phrase }
    let(:url) { 'https://example.com/example.png' }
    let(:image_data) do
      File.open(Rails.root.join('spec', 'testdata', 'example.png')).read
    end

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

    scenario 'Uploading an image from a URL' do
      successfully_visits_page new_image_entity_path(entity)

      fill_in 'image_title', with: image_title
      fill_in 'image_url', with: url

      expect(HTTParty).to receive(:get)
                            .with(url, stream_body: true)
                            .and_yield(image_data)
                            .and_return(double(:success? => true))

      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.title).to eql image_title
      expect(images.first.is_featured).to be false

      successfully_visits_page images_entity_path(entity)
    end
  end
end
