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

  describe 'adding an image to a entity' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:image_caption) { Faker::Creature::Dog.meme_phrase }
    let(:url) { 'https://example.com/example.png' }
    let(:image_data) { File.open(example_png).read }
    let(:image) { build(:image, entity: create(:entity_org)) }

    before do
      allow(HTTParty).to receive(:get)
                           .with(url, stream_body: true)
                           .and_yield(image_data)
                           .and_return(:success? => true)
      allow(Image).to receive(:new_from_url).and_return(image)

      visit concretize_new_entity_image_path(entity)
    end

    it 'uploads an image from a file' do
      successfully_visits_page concretize_new_entity_image_path(entity)

      attach_file 'image_file', example_png
      fill_in 'image_caption', with: image_caption
      check 'image_is_featured'
      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.caption).to eql image_caption
      expect(images.first.is_featured).to be true

      successfully_visits_page concretize_entity_images_path(entity)
    end

    it 'uploads an image from a URL' do
      successfully_visits_page concretize_new_entity_image_path(entity)

      fill_in 'image_caption', with: image_caption
      fill_in 'image_url', with: url

      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.caption).to eql image_caption

      successfully_visits_page concretize_entity_images_path(entity)
    end

    describe 'visting the crop image page' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:image) { create(:image, entity: create(:entity_org)) }

      before do
        setup_image_path image
        visit crop_ls_image_path(image)
      end

      it 'has crop html elements' do
        successfully_visits_page crop_ls_image_path(image)

        page_has_selector 'h3', text: 'Crop Image'
        page_has_selector '#image-wrapper > canvas', count: 1
      end
    end
  end

  describe 'featuring an image' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:featured_image) { create(:image, entity: create(:entity_org), is_featured: true) }
    let(:unfeatured_image) { create(:image, entity: featured_image.entity) }

    before do
      setup_image_path unfeatured_image
      visit concretize_entity_images_path(unfeatured_image.entity)
    end

    it 'sets is_featured to true' do
      within '.entity-images-table' do
        expect(unfeatured_image.is_featured).to be false
        click_on 'feature'
        expect(unfeatured_image.reload.is_featured).to be true
      end
    end
  end

  describe 'removing an image' do
    let(:image) { create(:image, entity: create(:entity_org)) }

    before do
      user.add_ability!(:delete)
      setup_image_path image
      visit concretize_entity_images_path(image.entity)
    end

    it 'removes the image' do
      within '.entity-images-table' do
        click_on 'remove'
      end

      expect(page).to show_success 'Image deleted'
      expect(image.reload.is_deleted).to be true
    end
  end

  describe 'cropping an image' do
    pending 'unable to implement'
  end
end
