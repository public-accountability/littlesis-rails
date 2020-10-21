describe Image, type: :model do
  let(:filename) { "#{Digest::MD5.hexdigest(Time.current.to_i.to_s)}.png" }

  def all_images_exist(filename)
    Image::IMAGE_TYPES.each do |img_type|
      expect(ImageFile.new(filename: filename, type: img_type).exists?).to be true
    end
  end

  def all_images_do_not_exist(filename)
    Image::IMAGE_TYPES.each do |img_type|
      expect(ImageFile.new(filename: filename, type: img_type).exists?).to be false
    end
  end

  describe 'validations, associations, and constants' do
    it { is_expected.not_to have_db_column(:title) }
    it { is_expected.not_to validate_presence_of(:caption) }
    it { is_expected.to validate_presence_of(:entity_id) }
    it { is_expected.to validate_presence_of(:filename) }
    it { is_expected.to belong_to(:entity).optional }
    it { is_expected.to belong_to(:user).optional }
    specify { expect(Image::IMAGE_SIZES).to be_a Hash }
  end

  describe '#image_file' do
    let(:image) { build(:image) }

    specify { expect(image.image_file).to be_a ImageFile }
    specify { expect(image.image_file.filename).to eq image.filename }
    specify { expect(image.image_file.type).to eq 'profile' }
  end

  describe 'Soft Delete / Destroy' do
    let(:entity) { create(:entity_org) }
    let(:image) { create(:image, entity: entity, is_featured: true) }
    let(:not_featured) { create(:image, entity: entity, is_featured: false) }

    describe 'soft_delete' do
      before { image }

      it 'changes is_deleted' do
        expect { image.soft_delete }.to change { image.is_deleted }.to(true)
      end
    end

    describe 'destroy' do
      before do
        image
        not_featured
      end

      it 'changes is_deleted' do
        expect { image.destroy }.to change { image.is_deleted }.to(true)
      end

      it 'destorying image also unfeatures the image' do
        expect { image.destroy }
          .to change { not_featured.reload.is_featured }
                .from(false).to(true)
      end
    end
  end

  describe 'title' do
    let(:entity) { build(:org, name: 'FooBar') }

    it 'returns caption if caption exists' do
      expect(build(:image, caption: 'my caption').title).to eq 'my caption'
    end

    it 'returns name of entity if entity exists' do
      expect(build(:image, caption: nil, entity: entity).title).to eq 'FooBar'
    end

    it 'returns blank string if there is no caption or entity' do
      expect(build(:image, caption: nil, entity: nil).title).to eq ''
    end
  end

  describe 'path & url' do
    let(:filename) { Image.random_filename }
    let(:image) { build(:image, filename: filename) }

    describe 'image_path' do
      specify do
        expect(image.image_path('large')).to eq "/images/large/#{filename.slice(0, 2)}/#{filename}"
      end
    end

    describe 'image_url' do
      specify do
        expect(image.image_url('large')).to eq "https://littlesis.org/images/large/#{filename.slice(0, 2)}/#{filename}"
      end
    end
  end

  describe 'dimensions' do
    let(:filename) { Image.random_filename('png') }
    let(:path_1200x900) { Rails.root.join('spec', 'testdata', '1200x900.png').to_s }
    let(:image) { build(:image, filename: filename, width: 1200, height: 900) }

    before { Image.create_image_variations(filename, path_1200x900) }

    it 'returns original dimensions' do
      d = image.dimensions
      expect(d.width).to eq 1200
      expect(d.height).to eq 900
    end

    it 'returns size of resized image' do
      d = image.dimensions('large')
      expect(d.width).to eq 1024
      expect(d.height).to eq 768
    end
  end

  describe 'feature/unfeature' do
    let!(:entity) { create(:entity_person) }
    let!(:featured_image) { create(:image, entity: entity, is_featured: true) }
    let!(:image) { create(:image, entity: entity, is_featured: false) }

    describe '#feature' do
      it 'sets is_featured to true' do
        expect { image.feature }
          .to change { image.reload.is_featured }.from(false).to(true)
      end

      it 'removes featured status from other images' do
        expect { image.feature }
          .to change { featured_image.reload.is_featured }.from(true).to(false)
      end
    end

    describe '#unfeature' do
      it 'sets is_featured to false' do
        expect { featured_image.unfeature }
          .to change { featured_image.reload.is_featured }.from(true).to(false)
      end

      it 'features another image' do
        expect { featured_image.unfeature }
          .to change { image.reload.is_featured }.from(false).to(true)
      end
    end
  end

  describe 'feature after creating' do
    let(:entity) { create(:entity_org) }

    it 'features image after creating' do
      entity.images.create!(filename: Image.random_filename)
      expect(entity.images.first.is_featured).to be true
    end

    it 'does not feature the image if another featured image exists' do
      featured_image = Image.create!(filename: Image.random_filename, is_featured: true, entity: entity)
      second_image = Image.create!(filename: Image.random_filename, entity: entity)
      expect(featured_image.reload.is_featured).to be true
      expect(second_image.reload.is_featured).to be false
    end
  end

  describe 'Class Methods' do
    describe 'random_filename' do
      it 'returns random file name with provided extension' do
        filename = Image.random_filename('svg')
        expect(filename.split('.')[0].length).to eql 32
        expect(filename.split('.')[1]).to eql 'svg'
      end

      it 'returns random file name with default extension' do
        filename = Image.random_filename
        expect(filename.split('.')[0].length).to eql 32
        expect(filename.split('.')[1]).to eql 'jpg'
      end

      it 'can accept file names with "."' do
        filename = Image.random_filename('.png')
        expect(filename.length).to eql 36
        expect(filename[-5]).not_to eql '.'
      end
    end

    describe 'file_ext_from' do
      it 'returns extension from url' do
        expect(Image.file_ext_from('https://example.com/example.png'))
          .to eql 'png'
      end

      it 'returns extension from path' do
        expect(Image.file_ext_from('/some/tmp/image.jpg')).to eql 'jpg'
      end

      it 'returns extension from path with spaces' do
        expect(Image.file_ext_from('this is an image.jpg')).to eq 'jpg'
      end

      it 'retrieves information from head if no extension found' do
        url = 'https://example.com/example_image'
        head = double('HTTParty::Response head double')
        expect(head).to receive(:success?).and_return true
        expect(head).to receive(:[]).with('content-type').and_return('image/jpg')
        expect(HTTParty).to receive(:head).with(url).and_return(head)
        expect(Image.file_ext_from(url)).to eql 'jpg'
      end

      it 'raises error if there is an invalid format' do
        url = 'https://example.com/example_image'
        head = double('HTTParty::Response head double')
        expect(head).to receive(:success?).and_return true
        expect(head).to receive(:[]).with('content-type').and_return('audio/mpeg3')
        expect(HTTParty).to receive(:head).with(url).and_return(head)
        expect { Image.file_ext_from(url) }
          .to raise_error { Image::InvalidFileExtensionError }
      end

      it 'raises error if request is a faliure' do
        url = 'https://example.com/example_image'
        head = double('HTTParty::Response head double')
        expect(head).to receive(:success?).and_return false
        expect(HTTParty).to receive(:head).with(url).and_return(head)

        expect { Image.file_ext_from(url) }
          .to raise_error { Image::RemoteImageRequestFailure }
      end

      it 'raises error if image is a path without a proper extension' do
        expect { Image.file_ext_from('/tmp/path/without/ext') }
          .to raise_error(Image::ImagePathMissingExtension)
      end
    end

    describe 'create_image_variation' do
      let(:filename) { Image.random_filename('png') }
      let(:path_1x1) { Rails.root.join('spec', 'testdata', '1x1.png').to_s }
      let(:path_40x60) { Rails.root.join('spec', 'testdata', '40x60.png').to_s }
      let(:path_1200x900) { Rails.root.join('spec', 'testdata', '1200x900.png').to_s }

      before do
        Image::IMAGE_TYPES.map(&:to_s).each do |img_type|
          FileUtils.mkdir_p Rails.root.join('tmp', img_type)
        end
      end

      it 'does nothing if image variation already exists (and check_first is true)' do
        image_file = ImageFile.new(filename: filename, type: 'small')
        FileUtils.mkdir_p image_file.pathname.dirname
        FileUtils.cp(path_1x1, image_file.path)
        expect(Image.create_image_variation(filename, 'small', path_1x1)).to eq :exists
      end

      context 'when height is larger than max size' do # 40x60, small
        let(:image_file) { ImageFile.new(filename: filename, type: 'small') }

        it 'resizes image' do
          expect(image_file.exists?).to be false
          expect(Image.create_image_variation(filename, 'small', path_40x60)).to eq :created
          expect(image_file.exists?).to be true
          newly_created_image = MiniMagick::Image.open(image_file.path)
          expect(newly_created_image.height).to eq 50
          expect(newly_created_image.width).to eq 33
        end
      end

      context 'when width is larger than max size' do # 1200x900, large
        let(:image_file) { ImageFile.new(filename: filename, type: 'large') }

        it 'resizes image' do
          expect(image_file.exists?).to be false
          expect(Image.create_image_variation(filename, 'large', path_1200x900)).to eq :created
          expect(image_file.exists?).to be true
          expect(MiniMagick::Image.open(image_file.path).width).to eq 1024
        end
      end

      context 'when height and wdith are smaller than max size' do
        let(:image_file) { ImageFile.new(filename: filename, type: 'small') }

        it 'does not resize image' do
          expect(image_file.exists?).to be false
          expect(Image.create_image_variation(filename, 'small', path_1x1)).to eq :created
          expect(image_file.exists?).to be true
          newly_created_image = MiniMagick::Image.open(image_file.path)
          expect(newly_created_image.width).to eq 1
          expect(newly_created_image.height).to eq 1
        end
      end
    end

    describe 'create_image_variations' do
      let(:filename) { Image.random_filename('png') }
      let(:path_1200x900) { Rails.root.join('spec', 'testdata', '1200x900.png').to_s }

      it 'creates 4 images' do
        all_images_do_not_exist(filename)
        Image.create_image_variations(filename, path_1200x900)
        all_images_exist(filename)
      end
    end

    describe 'new_from_url' do
      let(:filename) { Image.random_filename('png') }

      let(:temp_file) do
        Tempfile.new(['img', '.png']).tap do |f|
          f.write(File.open(Rails.root.join('spec', 'testdata', '40x60.png').to_s).read)
          f.rewind
        end
      end

      let(:url) { 'https://example.com/image.png' }

      it 'downloads image from url' do
        expect(Image).to receive(:save_image_to_tmp).with(url).and_return(temp_file.path)
        Image.new_from_url(url)
      end

      it 'raises error if image cannot be downloaded' do
        expect(Image).to receive(:save_image_to_tmp).with(url).and_return(false)
        expect { Image.new_from_url(url) }.to raise_error(Image::RemoteImageRequestFailure)
      end

      it 'raises error if image url is empty' do
        expect { Image.new_from_url(' ') }.to raise_error(/blank url/)
      end

      it 'raises error if url does not start with http' do
        expect { Image.new_from_url('/some/path') }.to raise_error(/Invalid url scheme/)
      end

      it 'creates 4 image variations' do
        expect(Image).to receive(:random_filename).once.with('png').and_return(filename)
        expect(Image).to receive(:save_http_to_tmp).once.with(url).and_return(temp_file.path)
        all_images_do_not_exist(filename)
        Image.new_from_url(url)
        all_images_exist(filename)
      end

      it 'returns new image with correct properties' do
        expect(Image).to receive(:random_filename).once.with('png').and_return(filename)
        expect(Image).to receive(:save_http_to_tmp).once.with(url).and_return(temp_file.path)
        new_image = Image.new_from_url(url)
        expect(new_image).to be_a Image
        expect(new_image.url).to eq url
        expect(new_image.filename).to eq filename
        expect(new_image.width).to eq 40
        expect(new_image.height).to eq 60
      end

      context 'submitting a data url' do
        let(:url) do
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="
        end

        it 'creates 4 image variations' do
          expect(Image).to receive(:random_filename).once.with('png').and_return(filename)
          all_images_do_not_exist(filename)
          Image.new_from_url(url)
          all_images_exist(filename)
        end
      end
    end

    describe 'new_from_upload' do
      let(:filename) { Image.random_filename('png') }
      let(:path_40x60) { Rails.root.join('spec', 'testdata', '40x60.png').to_s }

      let(:stringio) do
        StringIO.new(File.open(path_40x60).read).tap do |x|
          x.singleton_class.send(:define_method, 'original_filename') { 'this_file_was_uploaded.png' }
        end
      end

      it 'creates all image variations' do
        expect(Image).to receive(:random_filename).once.with('png').and_return(filename)
        all_images_do_not_exist(filename)
        Image.new_from_upload(stringio)
        all_images_exist(filename)
      end

      it 'returns image with correct properties' do
        expect(Image).to receive(:random_filename).once.with('png').and_return(filename)
        new_image = Image.new_from_upload(stringio)
        expect(new_image).to be_a Image
        expect(new_image.url).to eq nil
        expect(new_image.filename).to eq filename
        expect(new_image.width).to eq 40
        expect(new_image.height).to eq 60
      end
    end

    describe 'crop' do
      let(:filename) { Image.random_filename('png') }
      let(:path_1200x900) { Rails.root.join('spec', 'testdata', '1200x900.png').to_s }
      let(:mini_magick) { MiniMagick::Image.open(path_1200x900) }

      let(:original_image) do
        build(:image, filename: filename, entity: build(:org), width: 1200, height: 900).tap do |image|
          allow(image).to receive(:image_file).with('original')
                            .and_return(double(:mini_magick => mini_magick))
        end
      end

      context 'when ratio is 1' do
        let(:cropped_image) do
          Image.crop(original_image, type: 'original', ratio: 1.0, x: 500, y: 300, w: 400, h: 200)
        end

        it 'returns new image with null id and new filename, but keeps other props' do
          expect(cropped_image.id).to be nil
          expect(cropped_image.filename).not_to eq original_image.filename
          expect(cropped_image.entity_id).to eq original_image.entity_id
        end

        it 'new image has updated height and width values' do
          expect(cropped_image.height).to eq 200
          expect(cropped_image.width).to eq 400
        end

        it 'creates 4 image variations' do
          all_images_exist(cropped_image.filename)
        end
      end

      context 'when ratio is larger than 1' do
        let(:cropped_image) do
          Image.crop(original_image, type: 'original', ratio: 1.5, x: 100, y: 100, w: 400, h: 200)
        end

        it 'scales crop accordingly' do
          expect(cropped_image.height).to eq 300
          expect(cropped_image.width).to eq 600
        end
      end
    end
  end # end Class Methods
end
