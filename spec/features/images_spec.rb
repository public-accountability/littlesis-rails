describe 'Images' do
  before(:all) do
    %w[small profile large original square].each do |folder|
      FileUtils.mkdir_p Rails.root.join('tmp', folder)
    end
  end

  let(:entity) { create(:entity_person) }
  let(:user) { create_basic_user }

  before { login_as(user, :scope => :user) }
  after { logout(:user) }

  feature 'Adding an image to a entity' do
    let(:image_caption) { Faker::Creature::Dog.meme_phrase }
    let(:url) { 'https://example.com/example.png' }
    let(:image_data) do
      File.open(Rails.root.join('spec', 'testdata', 'example.png')).read
    end

    before { visit new_image_entity_path(entity) }

    scenario 'Uploading an image from a file' do
      successfully_visits_page new_image_entity_path(entity)

      attach_file 'image_file', Rails.root.join('spec', 'testdata', 'example.png')
      fill_in 'image_caption', with: image_caption
      check 'image_is_featured'
      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eql 1
      expect(images.first.caption).to eql image_caption
      expect(images.first.is_featured).to be true

      successfully_visits_page images_entity_path(entity)
    end

    scenario 'Uploading an image from a URL' do
      successfully_visits_page new_image_entity_path(entity)

      fill_in 'image_caption', with: image_caption
      fill_in 'image_url', with: url

      expect(HTTParty).to receive(:get)
                            .with(url, stream_body: true)
                            .and_yield(image_data)
                            .and_return(double(:success? => true))

      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.caption).to eql image_caption
      expect(images.first.is_featured).to be true

      successfully_visits_page images_entity_path(entity)
    end

    describe 'visting the crop image page' do
      let(:image) { create(:image, entity: create(:entity_org)) }
      let(:path_1x1) { Rails.root.join('spec', 'testdata', '1x1.png').to_s }

      before do
        FileUtils.mkdir_p image.image_file('original').pathname.dirname
        FileUtils.cp(path_1x1, image.image_file('original').path)

        visit crop_image_path(image)
      end

      it 'has crop html elements' do
        successfully_visits_page crop_image_path(image)

        page_has_selector 'h3', text: 'Crop Image'
        page_has_selector '#image-wrapper > canvas', count: 1

        expect(page.html).to include "return fetch(\"#{crop_image_path(image)}\""
      end
    end
  end
end
