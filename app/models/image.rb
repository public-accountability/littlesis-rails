class Image < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :images
  belongs_to :user, inverse_of: :image
  belongs_to :address, inverse_of: :images
  
  scope :featured, -> { where(is_featured: true) }
  scope :persons, -> { joins(:entity).where(entity: { primary_ext: 'Person' }) }

  IMAGE_SIZES = { small: 50, profile: 200, large: 1024 }

  # after_save :disguise_face, if: :is_featured, unless: :has_face
  before_destroy :unfeature, if: :is_featured

  validates_presence_of :entity_id, :filename, :title

  def download_large_to_tmp
    download_to_tmp(s3_url("large", true))
  end

  def download_profile_to_tmp
    download_to_tmp(s3_url("profile", true))
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

  def s3_url(type, ensure_protocol = false)
    url = image_path(type)

    if ensure_protocol and url.match(/^\/\//)
      url = "https:" + url
    end

    url
  end

  def s3_exists?(type)
    S3.s3.buckets[Lilsis::Application.config.aws_s3_bucket].objects["images/#{type}/#{filename}"].exists?
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
        url: url.match(/^https?:/) ? url : nil,
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
    ActiveRecord::Base.transaction do
      Image.where(entity_id: entity_id).where.not(id: id).update_all(is_featured: false)
      self.is_featured = true
      save
    end
  end

  def find_face(source_face_size = 50, scale = 0.333, output_size=200)
    download_large_to_tmp or download_profile_to_tmp
    finder = EyesFinder.new(tmp_path, source_face_size)
    unless finder.is_loaded
      File.delete(tmp_path)
      return false
    end
    eyes = finder.find_eyes
    unless rect = finder.face_rect
      File.delete(tmp_path)
      return false
    end
    x = rect.x
    y = rect.y + source_face_size/10
    w = rect.width
    h = rect.height
    if w > h
      x += (w-h)/2
      w = h
    else
      y += (h-w)/2
      h = w
    end
    sub = [w, h].min * scale
    x += sub/2
    y += sub/2
    w -= sub
    h -= sub
    img = MiniMagick::Image.open(tmp_path)
    img.crop("#{w}x#{h}+#{x}+#{y}")
    img.resize("#{output_size}x #{output_size}")
    # face_path = Rails.root.join("tmp", "faces", filename).to_s
    img.write(tmp_path)
    # File.delete(tmp_path)
    tmp_path
  end

  alias :face_to_tmp :find_face

  def self.new_from_street_view(location, size, pitch)
    url = "https://maps.googleapis.com/maps/api/streetview?size=#{size}&location=#{URI::encode(location)}&pitch=#{pitch}&key=#{Lilsis::Application.config.google_street_view_key}"
    
    # make sure image isn't blank
    tmp_path = Rails.root.join("tmp", "google-street-view-#{rand * 1000000}.jpg")
    open(tmp_path, 'wb') { |file| file << open(url).read }
    img = Magick::ImageList.new(tmp_path).first
    pixels = [img.get_pixels(0, 0, 1, 1).first, img.get_pixels(100, 100, 1, 1).first]
    if pixels.count { |pixel| ((pixel.red-58596).abs < 10) and ((pixel.green-58339).abs < 10) and ((pixel.blue-57311).abs < 10) } == pixels.count
      File.delete(tmp_path)
      return
    end
    File.delete(tmp_path)

    new_from_url(url)
  end

  def street_view?
    address_id.present?
  end

  def upload_face_outline(path = nil, source_face_size=50, scale=0.333, output_size=200)
    return false unless face_path = path || face_to_tmp(source_face_size, scale, output_size)
    # `convert #{face_path} -colorspace Gray -blur 0x10 -edge 2 -normalize -negate -blur 0x2 -charcoal 10 #{face_path}`
    # `convert #{face_path} -colorspace Gray -blur 0x3 -sigmoidal-contrast 2x20% -charcoal 10 -negate -median 10 #{face_path}`
    # `convert #{face_path} -colorspace Gray -despeckle -blur 0x3 -normalize -sigmoidal-contrast 2x10% -charcoal 10 -negate -median 5 #{face_path}`
    # `convert #{face_path} -blur 0x2 -charcoal 10 -negate #{face_path}`
    # `convert #{face_path} -colorspace Gray -blur 2 -brightness-contrast 0x50 -edge 3 -negate #{face_path}`
    # `mogrify -colorspace Gray -blur 0x1 -charcoal 20 -negate #{face_path}`
    # `mogrify -colorspace Gray -normalize -brightness-contrast -20x30 -charcoal 5 -negate #{face_path}
    # `mogrify -colorspace Gray -normalize -despeckle -brightness-contrast -20x10 -blur 0x2 -edge 10 -fx G #{tmp_path}`
    `convert #{face_path} -colorspace Gray -blur 0x3 -brightness-contrast 0x20 -negate -edge 3 -negate -median 10 -brightness-contrast -30x50 #{face_path}`
    return face_path
  end

  def upload_face(path = nil, source_face_size=50, scale=0.333, output_size=200)
    return false unless face_path = path || face_to_tmp(source_face_size, scale, output_size)
    result = self.class.create_asset(filename, 'face', face_path, output_size, output_size)
    File.delete(face_path)
    return result
  end

  def disguise_face(method = :sketch)
    found_face = false

    [50, 100, 20].each do |face_size|
      if face_to_tmp(face_size, -0.2)
        found_face = true
        break
      end
    end

    return false unless (found_face or download_profile_to_tmp)
    disguise_tmp(method)
    S3.upload_file(Lilsis::Application.config.aws_s3_bucket, "images/face/#{filename}", tmp_path, check_first = false)
    File.delete(tmp_path)
    true
  end

  def disguise_tmp(method = :sketch)
    # `mogrify -colorspace Gray -normalize -despeckle -blur 0x2 -edge 5 -fx G -paint 5 -blur 0x1 #{tmp_path}`

    options = {
      posteredges: '-w 10 -a 5',
      lichtenstein: '',
      woodcut: '-d 0',
      retinex: '-m RGB -f 50',
      sketch: '-k gray -c 175 -g',
      vintage3: '-S 0 -s none',
      stutter: '-s 20 -d xy',
      edges: '-w 1 -s 2'
    }

    `mogrify -colorspace Gray -normalize -despeckle #{tmp_path}`
    `#{Rails.root.join("lib", "scripts", method.to_s)} #{options[method]} #{tmp_path} #{tmp_path}`
    `mogrify -despeckle -normalize #{tmp_path}`
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
end