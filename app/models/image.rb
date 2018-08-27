# frozen_string_literal: true

class Image < ApplicationRecord
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :images, optional: true
  belongs_to :user, inverse_of: :image, optional: true
  belongs_to :address, inverse_of: :images, optional: true

  scope :featured, -> { where(is_featured: true) }
  scope :persons, -> { joins(:entity).where(entity: { primary_ext: 'Person' }) }

  IMAGE_SIZES = { small: 50, profile: 200, large: 1024 }.freeze
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

  def destroy
    soft_delete
  end

  def download_large_to_tmp
    download_to_tmp s3_url('large')
  end

  def download_profile_to_tmp
    download_to_tmp s3_ur('profile')
  end

  def download_original_to_tmp
    download_to_tmp(url)
  end

  def download_to_tmp(remote_url)
    file = open(tmp_path, 'wb')
    file << open(remote_url).read
    return true
  rescue OpenURI::HTTPError
    return false
  ensure
    file.close
  end

  def original_exists?
    HTTParty.head(url).code == 200
  rescue HTTParty::ResponseError, SocketError
    false
  end

  def self.s3_path(filename, type)
    "images/#{type}/#{filename}"
  end

  def self.s3_url(filename, type)
    "https://#{APP_CONFIG['asset_host']}/#{s3_path(filename, type)}"
  end

  singleton_class.send(:alias_method, :image_path, :s3_url)

  def s3_url(type)
    self.class.s3_url(filename, type)
  end

  alias_method :image_path, :s3_url

  def s3_exists?(type)
    S3.file_exists? "images/#{type}/#{filename}"
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

  # String --> String | Throws
  #
  # Derives the image format from the url.
  # It first tries to determine the format
  # from the ending of the url path. If that fails,
  # it performs a HEAD request to get the content-type.
  def self.file_ext_from(url)
    ext = File.extname(URI(url).path).tr('.', '').downcase
    return ext if VALID_EXTENSIONS.include?(ext)

    head = HTTParty.head(url)
    raise RemoteImageRequestFailure unless head.success?

    mime_type = head['content-type'].downcase
    return MIME_TYPES.fetch(mime_type) if MIME_TYPES.key?(mime_type)
    raise InvalidFileExtensionError
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

  # Downloads an image from url, resizes it, and uploads
  # the resized images to S3.
  #
  # String (url) --> Image | false
  #
  # This assumes that the image url has an filetype extension
  #   ie: http://example.com/image.png
  # a url without an extension will not work
  def self.new_from_url(url)
    # This method can accept remote and local paths
    if url.slice(0, 4).casecmp('http').zero?
      original_image_path = save_image_to_tmp(url)
    else
      original_image_path = url
    end

    return false if original_image_path.blank?
    filename = random_filename(file_ext_from(original_image_path))

    original = MiniMagick::Image.open(original_image_path)

    if ENV['SKIP_S3_UPLOAD'] || Rails.env.test?
      large = profile = small = true
    else
      large = create_asset(filename, 'large', original_image_path, max_width: 1024, max_height: 1024)
      profile = create_asset(filename, 'profile', original_image_path, max_width: 200, max_height: 200)
      small = create_asset(filename, 'small', original_image_path, max_width: 50, max_height: 50)
    end

    if large && profile && small
      new(filename: filename, url: url, width: original[:width], height: original[:height])
    else
      false
    end
  ensure
    File.delete(original_image_path) if File.exist?(original_image_path)
  end

  def self.create_asset(filename, type, read_path, max_width: nil, max_height: nil, check_first: true)
    begin
      img = MiniMagick::Image.open(read_path)
    rescue
      Rails.logger.info "MiniMagick failed to open the file: #{read_path}"
      return false
    end

    width = img[:width]
    height = img[:height]

    if (max_width && (width > max_width)) || (max_height && (height > max_height))
      w = max_width ||  img[:width]
      h = max_height || img[:height]
      img.resize([w, h].join("x"))
    end

    tmp_path = Rails.root.join("tmp", "#{type}_#{filename}").to_s
    img.write(tmp_path)
    result = S3.upload_file(remote_path: "images/#{type}/#{filename}", local_path: tmp_path, check_first: check_first)
    File.delete(tmp_path)
    result
  end

  def crop(x, y, w, h)
    download_large_to_tmp or download_profile_to_tmp
    img = MiniMagick::Image.open(tmp_path)
    img.crop("#{w}x#{h}+#{x}+#{y}")
    img.write(tmp_path)

    IMAGE_SIZES.each do |type, size|
      Image.create_asset(filename, type, tmp_path, max_width: size, max_height: size, check_first: false)
    end

    File.delete(tmp_path)
    invalidate_cloudfront_cache
    true
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

  def invalidate_cloudfront_cache
    if Lilsis::Application.config.cloudfront_distribtion_id
      CloudFront.new.invalidate([
        "/images/profile/#{filename}",
        "/images/small/#{filename}"
      ])
    end
  end

  private

  def tmp_path
    Rails.root.join('tmp', filename).to_s
  end
end
