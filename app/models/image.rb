class Image < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :images
  
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
  
  def s3_url(type)
    S3.url(image_path(type))
  end
        
  def image_path(type)
    ActionController::Base.helpers.asset_path("images/#{type}/#{filename(type)}")  
  end

  def filename(type=nil)
    return read_attribute(:filename) unless type == "square"
    fn = read_attribute(:filename) 
    fn.chomp(File.extname(fn)) + '.jpg'
  end
  
  def self.random_filename(file_type=nil)
    if file_type.nil?
      type = Lilsis::Application.config.deafult_image_file_type
    else
      type = file_type
    end
      
    return "#{SecureRandom.hex(16)}.#{type}" 
  end
  
  def tmp_path
    Rails.root.join("tmp", filename).to_s
  end

end