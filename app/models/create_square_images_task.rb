require 'aws/s3'

class CreateSquareImagesTask
  include DebuggableTask

  attr_accessor :limit, :list_id, :size, :check_first

  def initialize(options = {})
    options = {
      debug: false,
      limit: 100,
      list_id: nil,
      size: 300,
      check_first: false
    }.merge(options)
    
    options.each do |k, v|
      send(:"#{k}=", v)
    end
  end

  def execute
    images.each do |image|
      print_debug "Processing image #{image.id}..."
    end
  end

  def images
    if list_id
      List.find!(list_id).entities.collect(&:images).take(limit)
    else
      Image.active.limit(limit)
    end
  end
end