describe 'Images', js: true do
  include EntitiesHelper

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    %w[small profile large original square].each do |folder|
      FileUtils.mkdir_p Rails.root.join('tmp', folder)
    end
  end

  let(:path_1x1) { Rails.root.join('spec/testdata/1x1.png').to_s }
  let(:entity) { create(:entity_person) }
  let(:user) { create_editor }
  let(:example_png) { Rails.root.join('spec/testdata/example.png') }

  def setup_image_path(image)
    FileUtils.mkdir_p image.image_file('original').pathname.dirname
    FileUtils.cp(path_1x1, image.image_file('original').path)
  end

  before { login_as(user, :scope => :user) }

  after { logout(:user) }

  describe 'adding an image to a entity' do
    let(:image_caption) { Faker::Creature::Dog.meme_phrase }
    let(:url) { 'https://example.com/example.png' }
    let(:image_data) { File.open(example_png).read }
    let(:image) { build(:image, entity: create(:entity_org)) }

    before do
      allow(Utility).to receive(:stream_file)
                          .and_return(double("HTTP Response", "is_a?": true))
      allow(Image).to receive(:new_from_url).and_return(image)

      visit concretize_new_entity_image_path(entity)
    end

    # passes locally, but fails on circleci
    xit 'uploads an image from a file' do
      expect(page.current_path).to eq concretize_new_entity_image_path(entity)

      attach_file 'image_file', example_png
      fill_in 'image_caption', with: image_caption
      check 'image_is_featured'
      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.caption).to eql image_caption
      expect(images.first.is_featured).to be true

      expect(page.current_path).to eq concretize_entity_images_path(entity)
    end

    it 'uploads an image from a URL' do
      expect(page.current_path).to eq concretize_new_entity_image_path(entity)

      fill_in 'image_caption', with: image_caption
      fill_in 'image_url', with: url

      click_button 'Upload'

      images = entity.reload.images

      expect(images.size).to eq 1
      expect(images.first.caption).to eql image_caption

      expect(page.current_path).to eq concretize_entity_images_path(entity)
    end

    describe 'visting the crop image page', js: false  do # rubocop:disable RSpec/MultipleMemoizedHelpers
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

  describe 'removing an image', js: false do
    let(:image) { create(:image, entity: create(:entity_org)) }
    let(:user) { create_admin_user }

    before do
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

  describe "Requesting deletion", js: true do
    let(:image) { create(:image, entity: create(:entity_org)) }
    let(:user) { create_editor }

    before do
      setup_image_path image
      visit concretize_entity_images_path(image.entity)
    end

    scenario do
      page_has_selector 'a', text: 'Request Deletion'
      click_on "open_deletion_request_modal_#{image.id}"
      page_has_selector '.image-modal-dialog'
      page_has_selector '.modal-title', text: 'Request Image Deletion'
      page_has_no_selector '#image_deletion_request_pending'

      within '#modal' do
        fill_in 'justification', with: 'image no good'
        click_on 'Submit'
      end

      page_has_selector '#image_deletion_request_pending'
      expect(ImageDeletionRequest.last.justification).to eq 'image no good'
    end
  end
end
