# frozen_string_literal: true

# We store images on our file system:
#  images/original/prefix/filename.ext
#  images/small/prefix/filename.jpg
#  images/profile/prefix/filename.jpg
#  images/large/prefix/filename.jpg
class Image < ApplicationRecord
  include SoftDelete

  belongs_to :entity, inverse_of: :images, optional: true
  belongs_to :user, inverse_of: :image, optional: true
  # belongs_to :address, inverse_of: :images, optional: true
  has_many :deletion_requests, inverse_of: :image, foreign_key: 'source_id', class_name: 'ImageDeletionRequest'

  scope :featured, -> { where(is_featured: true) }
  scope :persons, -> { joins(:entity).where(entity: { primary_ext: 'Person' }) }

  IMAGE_HOST = Rails.application.config.littlesis.fetch(:image_host)
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

  DATA_URL_PREFIX_REGEX = %r{image/(jpeg|jpg|png);base64}i

  DEFAULT_FILE_TYPE = Rails.application.config.littlesis.fetch(:default_image_file_type, 'jpg')

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
    ImageFile.new(filename: self[:filename], type: type)
  end

  Dimensions = Struct.new(:width, :height)

  def dimensions(type = 'original')
    img = image_file(type).mini_magick
    Dimensions.new(img.width, img.height)
  ensure
    img&.destroy!
  end

  def destroy
    soft_delete
  end

  def original_exists?
    return false if url.nil?

    Utility.head_request(url).code == '200'
  rescue Net::HTTPBadResponse, SocketError, Net::ProtocolError
    false
  end

  def download_again
    if original_exists?
      original = Image.save_image_to_tmp(url)
      # Convert to jpeg unless format is a png or jpg
      unless %w[png jpeg jpg].include?(File.extname(original).delete('.').downcase)
        original = convert_to_jpg(original_image_path)
      end
      Image.create_image_variations(filename, original)
    end
  end

  def self.random_filename(file_type = nil)
    file_type = DEFAULT_FILE_TYPE if file_type.nil?
    file_type.slice!(0) if file_type[0] == '.'
    "#{SecureRandom.hex(16)}.#{file_type}"
  end

  class InvalidFileExtensionError < StandardError; end
  class InvalidDataUrlError < StandardError; end
  class CorruptImageFileError < StandardError; end
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

    head = Utility.head_request(url_or_path)
    raise RemoteImageRequestFailure unless head.is_a?(Net::HTTPSuccess)

    mime_type = head['content-type'].downcase

    if MIME_TYPES.key?(mime_type)
      return MIME_TYPES.fetch(mime_type)
    else
      raise InvalidFileExtensionError
    end
  end

  def self.save_http_to_tmp(url)
    file_path = Rails.root.join('tmp', "#{Digest::MD5.hexdigest(url)}.#{file_ext_from(url)}").to_s
    response = Utility.stream_file(url: url, path: file_path)
    if response.is_a?(Net::HTTPSuccess)
      file_path
    else
      false
    end
  end

  def self.save_data_url_to_tmp(url)
    prefix, encoded_data = url[5..].split(',')
    raise InvalidDataUrlError unless DATA_URL_PREFIX_REGEX.match?(prefix)

    ext = DATA_URL_PREFIX_REGEX.match(prefix)[1]
    file_path = Rails.root.join('tmp', "#{Digest::MD5.hexdigest(url)}.#{ext}").to_s
    File.open(file_path, 'wb') { |file| file.write Base64.decode64(encoded_data) }
    file_path
  end

  # Downloads url and saves images to temporary file
  #
  # String (url) --> String (file path) | throws
  def self.save_image_to_tmp(url)
    localpath = if url[0..4].casecmp('data:').zero?
                  save_data_url_to_tmp(url)
                else
                  save_http_to_tmp(url)
                end

    # Check that file exists and can be edited by MiniMagick
    if localpath.blank? || Utility.file_is_empty_or_nonexistent(localpath) || !MiniMagick::Image.new(localpath).valid?
      raise RemoteImageRequestFailure
    else
      localpath
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

    # Download and save original
    original_image_path = save_image_to_tmp(url)

    # Convert to jpeg unless format is a png or jpg
    unless %w[png jpeg jpg].include?(File.extname(original_image_path).delete('.').downcase)
      original_image_path = convert_to_jpg(original_image_path)
    end

    dimensions = Image::Dimensions.new(*MiniMagick::Image.new(original_image_path).dimensions)

    filename = filename || random_filename(file_ext_from(original_image_path))
    create_image_variations(filename, original_image_path)
    new(filename: filename,
        url: url_scheme == 'data' ? nil : url,
        width: dimensions.width,
        height: dimensions.height)
  ensure
    if original_image_path.present? && File.exist?(original_image_path)
      File.delete(original_image_path)
    end
  end

  def self.create_image_variations(filename, original_file, check_first: true)
    IMAGE_TYPES.each do |type|
      create_image_variation(filename, type, original_file, check_first: check_first)
    end
  end

  def self.create_image_variation(filename, type, read_path, check_first: true)
    image_file = ImageFile.new(filename: filename, type: type)
    return :exists if check_first && image_file.exists?

    if type.to_s == 'original'
      image_file.write(read_path)
    else
      img = MiniMagick::Image.open(read_path)
      max_size = IMAGE_SIZES.fetch(type.to_sym)

      if (img.width > max_size) || (img.height > max_size)
        img.resize "#{max_size}x#{max_size}"
        image_file.write(img)
      else
        image_file.write(read_path)
      end
    end
    :created
  end

  # Converts local file to jpg
  # Image.convert_to_jpg('/tmp/image.svg') saves /tmp/image.jpg and deletes original
  def self.convert_to_jpg(path)
    output_path = "#{path[0...path.rindex('.')]}.jpg"

    image = MiniMagick::Image.new(path)

    if image.valid?
      image.format('jpg').write(output_path)
      output_path
    else
      raise CorruptImageFileError
    end
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
