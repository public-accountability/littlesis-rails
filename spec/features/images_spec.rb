describe 'Images' do
  include EntitiesHelper

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    %w[small profile large original square].each do |folder|
      FileUtils.mkdir_p Rails.root.join('tmp', folder)
    end
  end

  let(:path_1x1) { Rails.root.join('spec/testdata/1x1.png').to_s }
  let(:entity) { create(:entity_person) }
  let(:user) { create_basic_user }
  let(:example_png) { Rails.root.join('spec/testdata/example.png') }

  def setup_image_path(image)
    FileUtils.mkdir_p image.image_file('original').pathname.dirname
    FileUtils.cp(path_1x1, image.image_file('original').path)
  end

  before { login_as(user, :scope => :user) }

  after { logout(:user) }

  feature 'Adding an image to a entity' do
    let(:image_caption) { Faker::Creature::Dog.meme_phrase }
    let(:url) { 'https://example.com/example.png' }
    let(:image_data) { File.open(example_png).read }

    before { visit concretize_new_image_entity_path(entity) }

    scenario 'Uploading an image from a file' do
      successfully_visits_page concretize_new_image_entity_path(entity)

      attach_file 'image_file', example_png
      fill_in 'image_caption', with: image_caption
      check 'image_is_featured'
      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.caption).to eql image_caption
      expect(images.first.is_featured).to be true

      successfully_visits_page concretize_images_entity_path(entity)
    end

    scenario 'Uploading an image from a URL' do
      successfully_visits_page concretize_new_image_entity_path(entity)

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

      successfully_visits_page concretize_images_entity_path(entity)
    end

    describe 'visting the crop image page' do
      let(:image) { create(:image, entity: create(:entity_org)) }

      before do
        setup_image_path image
        visit crop_ls_image_path(image)
      end

      it 'has crop html elements' do
        successfully_visits_page crop_ls_image_path(image)

        page_has_selector 'h3', text: 'Crop Image'
        page_has_selector '#image-wrapper > canvas', count: 1

        expect(page.html).to include "return fetch(\"#{crop_ls_image_path(image)}\""
      end
    end
  end

  feature 'editing an image' do
    let(:image) { create(:image, entity: create(:entity_org)) }

    before do
      setup_image_path image
      visit crop_ls_image_path(image)
    end

    it 'has fields to edit caption'
  end
end
