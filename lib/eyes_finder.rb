require 'opencv'
include OpenCV

class EyesFinder
  attr_reader :face_rect, :face_rects, :eye_points, :is_loaded

  def initialize(path, face_size = 100)
    @path = path
    @face_size = face_size
    @face_detector = CvHaarClassifierCascade::load(Rails.root.join("data", "haar-cascades", "haarcascade_frontalface_default.xml").to_s)
    @eye_detector = CvHaarClassifierCascade::load(Rails.root.join("data", "haar-cascades", "haarcascade_eye.xml").to_s)
    @is_loaded = true
    begin
      @image = IplImage.load(path)
      @gray = IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE)
    rescue => e
      @is_loaded = false
    end
    @face_rects = []
    @eye_points = []
  end

  def find_eyes(min_size = 10)
    face_size = CvSize.new(@face_size, @face_size)
    eye_size = CvSize.new(min_size, min_size)
    @face_rects = @face_detector.detect_objects(@gray, min_size: face_size, min_neighbors: 3)
    @face_rects.each do |face|
      face_rect = CvRect.new(face.x, face.y, face.width, face.height)
      face_gray = @gray.set_roi(face_rect)
      @eye_regions = @eye_detector.detect_objects(face_gray, min_size: eye_size, min_neighbors: 3)      
      eye_points = @eye_regions.map(&:center)
      eye_points.select! { |eye| eye.y < face.height/2 } # eyes must be in top half of face
      eye_points.map! { |p| add_points(face.top_left, p) }

      # must find at least two eyes
      next unless eye_points.count > 1

      # return pair of eyes that are most horizontally aligned but sufficiently far apart
      diffs = []
      eye_points.each_with_index do |p1, i|
        eye_points.each_with_index do |p2, j|
          next unless j > i
          diffs << [(p1.x - p2.x).abs, (p1.y - p2.y).abs, p1, p2]
        end
      end
      wide_diffs = diffs.select { |ary| ary.first > face.width/4.to_f }
      next if wide_diffs.count == 0
      @face_rect = face_rect if @face_rect.nil?
      @eye_points << wide_diffs.min_by { |ary| ary[1] }.drop(2).sort_by(&:x)
    end

    @face_rect = @face_rects.first if @face_rect.nil?
    @eye_points
  end

  def find_eye_center(region)
    rect = CvRect.new(region.x, region.y, region.width, region.height)
    eye_gray = @gray.set_roi(rect)
    min = eye_gray.min_max_loc[0]
    eye_dark = eye_gray.lt(min + 10)
    param = CvSURFParams.new(500)
    points, descriptors = object.extract_surf(param)
    binding.pry
  end

  def log_eyes
    image = IplImage.load(@path)
    # @eye_regions.each do |region|
    #   image.rectangle!(region.top_left, region.bottom_right, color: CvColor::Blue, thickness: 2)
    # end
    @eye_points.first.each do |point|
      image.circle!(point, 10, color: CvColor::Blue, thickness: 2)
    end
    output_path = "eye-log/#{File.basename(@path)}"
    image.save(output_path)
    print "logged eyes to #{output_path}\n"
  end

  def add_points(p1, p2)
    CvPoint.new(p1.x + p2.x, p1.y + p2.y)
  end
end