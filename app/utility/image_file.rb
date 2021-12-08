# frozen_string_literal: true

# Very simple wrapper around File, used by Image
class ImageFile
  IMAGE_ROOT = Rails.application.config.littlesis.image_root

  attr_reader :path, :type, :filename

  def initialize(filename:, type:)
    unless Image::IMAGE_TYPES.include?(type.to_s.downcase.to_sym)
      raise Exceptions::LittleSisError, "Invalid image type: #{type}"
    end

    @filename = filename
    @type = type.to_s.downcase
    @path = Rails.root.join(IMAGE_ROOT, @type, @filename.slice(0, 2), @filename).to_s
  end

  def exists?
    File.exist?(@path) && !File.zero?(@path)
  end

  def write(img)
    make_dir_prefix
    if img.is_a?(MiniMagick::Image)
      img.write(@path)
    elsif File.exist?(img) # assumes img is a String or Pathname
      FileUtils.cp(img, @path)
    else
      raise Exceptions::LittleSisError, "Cannot write image: #{img.class}"
    end
    File.chmod(0o644, @path)
  end

  def pathname
    Pathname.new(@path)
  end

  def mini_magick
    MiniMagick::Image.open(@path)
  end

  private

  def make_dir_prefix
    FileUtils.mkdir_p File.join(pathname.dirname), mode: 0o775
  end
end
