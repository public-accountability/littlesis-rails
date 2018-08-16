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

  DEFAULT_FILE_TYPE = Lilsis::Application.config.default_image_file_type

  before_destroy :unfeature, if: :is_featured

  validates :entity_id, presence: true
  validates :filename, presence: true
  validates :title, presence: true

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
    open(tmp_path, 'wb') do |file|
      begin
        file << open(remote_url).read  
      rescue OpenURI::HTTPError
        return false
      end
      file.close
    end
    true
  end

  def original_exists?
    uri = URI(url)

    request = Net::HTTP.new(uri.host)
    response = request.request_head(uri.path)
    response.code.to_i == 200
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
    "#{SecureRandom.hex(16)}.#{file_type}"
  end

  def self.new_from_url(url)
    # This assumes that the image url has an filetype extension
    #   ie: http://example.com/image.png
    # a url fwithout an extension will not work
    filename = random_filename(URI(url).path[-3, 3])

    begin
      original = MiniMagick::Image.open(url)
    rescue => e
      Rails.logger.info "Failed to open: #{url}"
      Rails.logger.debug e.message
      Rails.logger.debug e.backtrace.join('\n')
      return false
    end

    if ENV['SKIP_S3_UPLOAD']
      large = profile = small = true
    else
      large = create_asset(filename, 'large', url, 1024, 1024)
      profile = create_asset(filename, 'profile', url, 200, 200)
      small = create_asset(filename, 'small', url, 50, 50)
    end

    if large && profile && small
      return new(filename: filename,
                 url: url.match?(/^https?:/) ? url : nil,
                 width: original[:width],
                 height: original[:height])
    else
      return false
    end
  end

  def self.create_asset(filename, type, read_path, max_width = nil, max_height = nil, check_first = true)
    begin
      img = MiniMagick::Image.open(read_path)
    rescue
      return false
    end

    width = img[:width]
    height = img[:height]

    if (max_width && (width > max_width)) || (max_height && (height > max_height))
      w = max_width ? max_width : img[:width]
      h = max_height ? max_height : img[:height]
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
      self.class.create_asset(filename, type, tmp_path, size, size, false)
    end

    File.delete(tmp_path)
    invalidate_cloudfront_cache
    true
  end

  def ensure_large_s3
    if s3_exists?('large')
      return :exists
    else
      if (original_exists? rescue false)
        Image.create_asset(filename, 'large', url, Image::IMAGE_SIZES[:large], Image::IMAGE_SIZES[:large], false)
        return :created
      else
        return false
      end
    end
  end

  def feature
    ApplicationRecord.transaction do
      Image.where(entity_id: entity_id).where.not(id: id).update_all(is_featured: false)
      self.is_featured = true
      save
    end
  end

  def unfeature
    self.is_featured = false

    if new_featured = Image.where(entity_id: entity_id).where.not(id: id).first
      new_featured.update(is_featured: true)
    end
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
