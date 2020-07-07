# frozen_string_literal: true

# We store images on our file system:
#  images/original/prefix/filename.ext
#  images/small/prefix/filename.jpg
#  images/profile/prefix/filename.jpg
#  images/large/prefix/filename.jpg
#  images/square/prefix/filename/jpg
class Image < ApplicationRecord
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :images, optional: true
  belongs_to :user, inverse_of: :image, optional: true
  belongs_to :address, inverse_of: :images, optional: true
  has_many :deletion_requests, inverse_of: :image, foreign_key: 'source_id', class_name: 'ImageDeletionRequest'

  scope :featured, -> { where(is_featured: true) }
  scope :persons, -> { joins(:entity).where(entity: { primary_ext: 'Person' }) }

  IMAGE_HOST = APP_CONFIG.fetch('image_host')
  IMAGE_SIZES = { small: 50, profile: 200, large: 1024, original: nil }.freeze
  IMAGE_TYPES = IMAGE_SIZES.keys.freeze

  MIME_TYPES = {
    'image/svg+xml' => 'svg',
    'image/jpeg' => 'jpg',
    'image/jpg' => 'jpg',
    'image/gif' => 'gif'
  }.freeze

  VALID_MIME_TYPES = MIME_TYPES.values.freeze
  VALID_EXTENSIONS = %w[jpg jpeg svg png].to_set.freeze

  DATA_URL_PREFIX_REGEX = /image\/(jpeg|jpg|png|gif);base64/i

  DEFAULT_FILE_TYPE = APP_CONFIG['default_image_file_type']

  before_soft_delete :unfeature, if: :is_featured

  after_create :feature, if: -> { !entity.has_featured_image }

  validates :entity_id, presence: true
  validates :filename, presence: true

  def title
    if caption.present?
      caption
    elsif entity.present?
      entity.name
    else
      ''
    end
  end

  def image_path(type)
    "/images/#{type}/#{filename.slice(0, 2)}/#{filename}"
  end

  def image_url(type)
    URI.join(IMAGE_HOST, image_path(type)).to_s
  end

  def image_file(type = 'profile')
    ImageFile.new(filename: read_attribute(:filename), type: type)
  end

  Dimensions = Struct.new(:width, :height)

  def dimensions(type = 'original')
    img = image_file(type).mini_magick
    Dimensions.new(img.width, img.height)
  ensure
    img.destroy!
  end

  ######### s3 legacy methods ##############3

  # def self.s3_path(filename, type)
  #   "images/#{type}/#{filename}"
  # end

  # def self.s3_url(filename, type)
  #   "https://#{APP_CONFIG['image_asset_host']}/#{s3_path(filename, type)}"
  # end

  # singleton_class.send(:alias_method, :image_path, :s3_url)

  # def s3_url(type)
  #   self.class.s3_url(filename, type)
  # end

  # alias_method :image_path, :s3_url

  ######### s3 legacy methods ##############3

  def destroy
    soft_delete
  end

  def original_exists?
    HTTParty.head(url).code == 200
  rescue HTTParty::ResponseError, SocketError
    false
  end

  def filename(type=nil)
    return read_attribute(:filename) unless type == "square"
    fn = read_attribute(:filename)
    fn.chomp(File.extname(fn)) + '.jpg'
  end

  def self.random_filename(file_type = nil)
    file_type = DEFAULT_FILE_TYPE if file_type.nil?
    file_type.slice!(0) if file_type[0] == '.'
    "#{SecureRandom.hex(16)}.#{file_type}"
  end

  class InvalidFileExtensionError < StandardError; end
  class InvalidDataUrlError < StandardError; end
  class RemoteImageRequestFailure < StandardError; end
  class ImagePathMissingExtension < StandardError; end

  # String --> String | Throws
  #
  # Derives the image format from the url.
  # It first tries to determine the format
  # from the ending of the url path. If that fails,
  # it performs a HEAD request to get the content-type.
  def self.file_ext_from(url_or_path)
    ext = File.extname(url_or_path).tr('.', '').downcase
    return ext if VALID_EXTENSIONS.include?(ext)

    uri = URI(url_or_path)
    raise ImagePathMissingExtension if uri.scheme.nil?

    head = HTTParty.head(url_or_path)
    raise RemoteImageRequestFailure unless head.success?

    mime_type = head['content-type'].downcase

    if MIME_TYPES.key?(mime_type)
      return MIME_TYPES.fetch(mime_type)
    else
      raise InvalidFileExtensionError
    end
  end

  def self.save_http_to_tmp(url)
    file_path = Rails.root.join('tmp', "#{Digest::MD5.hexdigest(url)}.#{file_ext_from(url)}").to_s
    file = File.open(file_path, 'wb')
    response = HTTParty.get(url, stream_body: true) { |fragment| file.write(fragment) }
    return response.success? ? file_path : false
  ensure
    file.close
  end

  def self.save_data_url_to_tmp(url)
    prefix, encoded_data = url[5..].split(',')
    # binding.pry
    raise InvalidDataUrlError unless DATA_URL_PREFIX_REGEX.match?(prefix)

    ext = DATA_URL_PREFIX_REGEX.match(prefix)[1]
    file_path = Rails.root.join('tmp', "#{Digest::MD5.hexdigest(url)}.#{ext}").to_s
    File.open(file_path, 'wb') { |file| file.write  Base64.decode64(encoded_data) }
    file_path
  end

  # Downloads url and saves images to temporary file
  #
  # String (url) --> String (file path) | false
  def self.save_image_to_tmp(url)
    if url[0..4].casecmp('data:').zero?
      save_data_url_to_tmp(url)
    else
      save_http_to_tmp(url)
    end
  end

  # Subclass of IO --> Image
  def self.new_from_upload(uploaded)
    ext = file_ext_from(uploaded.original_filename)
    original_file = MiniMagick::Image.read(uploaded, ".#{ext}")
    filename = random_filename(ext)
    create_image_variations(filename, original_file.path)
    new(filename: filename, width: original_file.width, height: original_file.height)
  end

  # Downloads an image from url and creates variations
  #
  # String (url) --> Image | false
  #
  # This assumes that the image url has an filetype extension
  #   ie: http://example.com/image.png
  #
  # a url without an extension may work if the url returns a valid mime type
  def self.new_from_url(url)
    raise Exceptions::LittleSisError, 'Image.new_from_url called with a blank url' if url.blank?
    url_scheme = URI(url).scheme
    raise Exceptions::LittleSisError, 'Invalid url scheme' unless %w[http https data].include?(url_scheme)

    original_image_path = save_image_to_tmp(url)

    raise RemoteImageRequestFailure if original_image_path.blank?

    original_file = MiniMagick::Image.open(original_image_path)

    filename = random_filename(file_ext_from(original_image_path))
    create_image_variations(filename, original_image_path)
    new(filename: filename,
        url: url_scheme == 'data' ? nil : url,
        width: original_file.width,
        height: original_file.height)
  ensure
    File.delete(original_image_path) if original_image_path.present? && File.exist?(original_image_path)
  end

  def self.create_image_variations(filename, original_file, check_first: true)
    IMAGE_TYPES.each do |type|
      create_image_variation(filename, type, original_file, check_first: check_first)
    end
  end

  def self.create_image_variation(filename, type, read_path, check_first: true)
    image_file = ImageFile.new(filename: filename, type: type)
    return :exists if check_first && image_file.exists?

    img = MiniMagick::Image.open(read_path)

    max_size = IMAGE_SIZES.fetch(type.to_sym)

    # resize the image unless it's already smaller than the max size
    # or max size is missing (i.e. type == original)
    if max_size && ((img.width > max_size) || (img.height > max_size))
      img.resize "#{max_size}x#{max_size}"
    end

    image_file.write(img)
    :created
  ensure
    img&.destroy!
  end

  # inputs:
  #   image -> Image
  #   type  -> String (original, large, etc.)
  #   ratio -> Float
  #   x, y  -> Float/Int. Starting point for crop
  #   h, y  -> Float/Int. How much to cut out
  #
  # Returns new Image, not persisted, just like new_from_url and new_from_upload
  # The image is created with .dup()
  #
  # Caller is responsible for handling logic of deleting or replacing previous image.
  def self.crop(image, type:, ratio:, x:, y:, h:, w:)
    crop_geometry = "#{w * ratio}x#{h * ratio}+#{x * ratio}+#{y * ratio}"
    img = image.image_file(type).mini_magick
    img.crop crop_geometry

    filename = random_filename file_ext_from(img.path)
    create_image_variations filename, img.path

    image.dup.tap do |i|
      i.assign_attributes(filename: filename, width: img.width, height: img.height)
    end
  ensure
    img.destroy!
  end

  # Deletes old image and saves new image inside a transaction
  def self.replace(old_image:, new_image:)
    ApplicationRecord.transaction do
      old_image.soft_delete
      new_image.save!
      Rails.logger.info "[crop] Replaced Image\##{old_image.id} (#{old_image.filename}) with Image\##{new_image.id} (#{new_image.filename})"
    end
  end

  def feature
    return self if is_featured

    ApplicationRecord.transaction do
      Image.where(entity_id: entity_id).where.not(id: id).update_all(is_featured: false)
      update!(is_featured: true)
    end
    self
  end

  def unfeature
    return self unless is_featured

    self.class.transaction do
      update!(is_featured: false)
      if (new_featured = Image.where(entity_id: entity_id).where.not(id: id).first)
        new_featured.update!(is_featured: true)
      end
    end

    self
  end
end
