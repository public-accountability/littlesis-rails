class Image < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :images
  
  scope :featured, -> { where(is_featured: true) }

  IMAGE_SIZES = { small: 50, profile: 200, large: 1024 }

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

  def original_exists?
    uri = URI(url)

    request = Net::HTTP.new(uri.host)
    response = request.request_head(uri.path)
    response.code.to_i == 200
  end
  
  def self.s3_url(filename, type)
    S3.url(image_path(filename, type))
  end

  def s3_url(type)
    image_path(type)
  end

  def s3_exists?(type)
    S3.s3.buckets[Lilsis::Application.config.aws_s3_bucket].objects["images/#{type}/#{filename}"].exists?
  end

  def self.image_path(filename, type)
    "https:" + ActionController::Base.helpers.asset_path("images/#{type}/#{filename}")  
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
      # RMagick can't seem to open remote files?
      original = MiniMagick::Image.open(url)
    rescue
      return false
    end

    if ENV['SKIP_S3_UPLOAD']
      large = profile = small = true
    else
      large = create_asset(filename, 'large', url, 1024, 1024)
      profile = create_asset(filename, 'profile', url, 200, 200)
      small = create_asset(filename, 'small', url, 50, 50)
    end

    if large and profile and small
      return new({
        filename: filename,
        url: url,
        width: original[:width],
        height: original[:height]
      })
    else
      return false
    end
  end

  def self.create_asset(filename, type, read_path, max_width = nil, max_height = nil, check_first = true)
    begin
      # RMagick can't seem to open remote files?
      img = MiniMagick::Image.open(read_path)
    rescue
      return false
    end

    width = img[:width]
    height = img[:height]

    if (max_width and width > max_width) or (max_height and height > max_height)
      w = max_width ? max_width : img[:width]
      h = max_height ? max_height : img[:height]
      img.resize([w, h].join("x"))
    end

    tmp_path = Rails.root.join("tmp", "#{type}_#{filename}").to_s
    img.write(tmp_path)
    result = S3.upload_file(Lilsis::Application.config.aws_s3_bucket, "images/#{type}/#{filename}", tmp_path, check_first)
    File.delete(tmp_path)
    result
  end

  def crop(x, y, w, h)
    download_large_to_tmp
    img = MiniMagick::Image.open(tmp_path)
    img.crop("#{w}x#{h}+#{x}+#{y}")
    img.write(tmp_path)

    IMAGE_SIZES.each do |type, size|
      self.class.create_asset(filename, type, tmp_path, size, size, false)
    end

    File.delete(tmp_path)
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
end