# frozen_string_literal: true

# Very simple wrapper around File
# used by Image
class ImageFile
  IMAGE_ROOT = APP_CONFIG['image_root']

  attr_reader :path, :type, :filename

  def initialize(filename:, type:)
    unless Image::IMAGE_TYPES.include?(type.to_s.downcase.to_sym)
      raise Exceptions::LittleSisError, "Invalid image type: #{type}"
    end

    @filename = filename
    @type = type.to_s.downcase
    @path = File.join(IMAGE_ROOT, @type, @filename.slice(0, 2), @filename)
  end

  def exists?
    File.exist?(@path) && !File.zero?(@path)
  end

  def write(img)
    TypeCheck.check img, MiniMagick::Image
    make_dir_prefix
    img.write(@path)
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
