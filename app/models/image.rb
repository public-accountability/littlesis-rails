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

  DEFAULT_FILE_TYPE = Lilsis::Application.config.default_image_file_type

  before_soft_delete :unfeature, if: :is_featured

  validates :entity_id, presence: true
  validates :filename, presence: true
  validates :title, presence: true

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

  class InvalidFileExtensionError < StandardError
  end

  class RemoteImageRequestFailure < StandardError
  end

  class ImagePathMissingExtension < StandardError
  end

  # String --> String | Throws
  #
  # Derives the image format from the url.
  # It first tries to determine the format
  # from the ending of the url path. If that fails,
  # it performs a HEAD request to get the content-type.
  def self.file_ext_from(url_or_path)
    uri = URI(url_or_path)

    ext = File.extname(uri.path).tr('.', '').downcase
    return ext if VALID_EXTENSIONS.include?(ext)

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

  # Downloads url and saves images to temporary file
  #
  # String (url) --> String (file path) | false
  def self.save_image_to_tmp(url)
    file_path = Rails.root.join('tmp', "#{Digest::MD5.hexdigest(url)}.#{file_ext_from(url)}").to_s
    file = File.open(file_path, 'wb')
    response = HTTParty.get(url, stream_body: true) { |fragment| file.write(fragment) }
    if response.success?
      file_path
    else
      false
    end
  ensure
    file.close
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
    if url.blank?
      raise Exceptions::LittleSisError, 'Image.new_from_url called with a blank url'
    elsif url.casecmp('http') == -1
      raise Exceptions::LittleSisError, 'url does not start with "http"'
    end

    original_image_path = save_image_to_tmp(url)
    raise RemoteImageRequestFailure if original_image_path.blank?

    original_file = MiniMagick::Image.open(original_image_path)

    filename = random_filename(file_ext_from(original_image_path))
    create_image_variations(filename, original_image_path)
    new(filename: filename, url: url, width: original_file.width, height: original_file.height)
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
  # Returns new Image (unpersisted). Caller is responsible for
  # handling logic of replaces entity images
  def self.crop(image, type:, ratio:, x:, y:, h:, w:)

    # img = 

    # download_large_to_tmp or download_profile_to_tmp
    # img = MiniMagick::Image.open(tmp_path)
    # img.crop("#{w}x#{h}+#{x}+#{y}")
    # img.write(tmp_path)

    # IMAGE_SIZES.each do |type, size|
    #   Image.create_asset(filename, type, tmp_path, max_width: size, max_height: size, check_first: false)
    # end

    # File.delete(tmp_path)
    # invalidate_cloudfront_cache
    # true
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
