require 'rmagick'

class Image < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :images
  
  scope :featured, -> { where(is_featured: true) }

  def download_large_to_tmp
    download_to_tmp(s3_url("large"))
  end
  
  def download_original_to_tmp
    download_to_tmp(url)
  end
  
  def download_to_tmp(remote_url)
    open(tmp_path, "wb") do |file|
      begin 
        file << open(remote_url).read  
      rescue OpenURI::HTTPError
        return false
      end
      file.close
    end
    true
  end
  
  def self.s3_url(filename, type)
    S3.url(image_path(filename, type))
  end

  def s3_url(type)
    S3.url(image_path(type))
  end

  def self.image_path(filename, type)
    ActionController::Base.helpers.asset_path("images/#{type}/#{filename}")  
  end

  def image_path(type)
    self.class.image_path(filename(type), type)
  end

  def filename(type=nil)
    return read_attribute(:filename) unless type == "square"
    fn = read_attribute(:filename) 
    fn.chomp(File.extname(fn)) + '.jpg'
  end

  def self.random_filename(file_type=nil)
    if file_type.nil?
      type = Lilsis::Application.config.default_image_file_type
    else
      type = file_type
    end
      
    return "#{SecureRandom.hex(16)}.#{type}" 
  end
  
  def tmp_path
    Rails.root.join("tmp", filename).to_s
  end

  # mimics legacy php filename generator
  def self.generate_filename(original = nil)
    Digest::SHA2.hexdigest(Digest::MD5.hexdigest(original + Time.now.to_i.to_s + rand(1000..9999))) + "_" + Time.now.to_i.to_s + "." + Lilsis::Application.config.default_image_file_type
  end

  def self.new_from_url(url)
    filename = random_filename

    begin
      original = Magick::Image.read(url)
    rescue
      return false
    end

    large = create_asset(filename, 'large', url, 1024, 1024)
    profile = create_asset(filename, 'profile', url, 200, 200)
    small = create_asset(fiilename, 'small', url, 50, 50)

    if large and profile and small
      return new({
        filename: filename,
        url: url,
        width: original.columns,
        height: original.rows
      })
    else
      return false
    end
  end

  def self.create_asset(filename, type, read_path, max_width = nil, max_height = nil)
    begin
      img = Magick::Image.read(read_path)[0]
    rescue
      return false
    end

    width = img.columns
    height = img.rows

    ratio = if max_width > width and max_height > height
      width_ratio = max_width/width.to_f
      height_ratio = max_height/height.to_f
      [width_ratio, height_ratio].min
    elsif max_width > width
      max_width/width.to_f
    elsif max_height > height
      max_height/height.to_f
    else
      1
    end

    img.resize!(ratio)

    tmp_path = Rails.root.join("tmp", "#{type}_#{filename}").to_s
    img.write(tmp_path)
    result = S3.upload_file(Lilsis::Application.config.aws_s3_bucket, "images/#{type}/#{filename}", tmp_path)
    File.delete(tmp_path)
    result
  end
end