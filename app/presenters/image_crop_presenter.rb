# frozen_string_literal: true

# Wraps +Image+ for the image cropping tool, used by ImagesController
class ImageCropPresenter < SimpleDelegator
  # When cropping we ideally want to use the "original" image (it doesn't exist for all images).
  # Some original images will be too large to reasonably fit on the page.
  # We can scale the image to a suitable size as we normally do when displaying images on a page.
  # However, we need keep track of the ratio so that later on ImageMagick correctly crop the image.
  CropImageDimensions = Struct.new(:type, :ratio, :width, :height)

  WIDTH_THRESHOLD = 900.to_f

  def image_width_px
    "#{image_dimensions.width}px"
  end

  def image_height_px
    "#{image_dimensions.height}px"
  end

  def image_dimensions
    return @image_dimensions if defined?(@image_dimensions)

    dimensions = dimensions(type_for_crop)

    if dimensions.width <= WIDTH_THRESHOLD
      @image_dimension = CropImageDimensions.new(type_for_crop, 1.0, dimensions.width, dimensions.height)
    else
      ratio = dimensions.width / WIDTH_THRESHOLD

      @image_dimension = CropImageDimensions.new(type_for_crop,
                                                 ratio.round(3),
                                                 WIDTH_THRESHOLD,
                                                 (dimensions.height / ratio).round(3))
    end
  end

  def type_for_crop
    return @type_for_crop if defined?(@type_for_crop)

    if image_file('original').exists?
      @type_for_crop = 'original'
    elsif image_file('large').exists?
      @type_for_crop = 'large'
    else
      @type_for_crop = 'profile'
    end
  end
end
