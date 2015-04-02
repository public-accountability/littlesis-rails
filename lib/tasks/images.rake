namespace :images do
  desc "creates square versions of images"
  task create_square: :environment do
    options = {}
    %w(LIMIT LIST_ID SIZE CHECK_FIRST DEBUG).each do |option|
      value = ENV[option]
      options[option.downcase] = value unless value.nil?
    end

    task = CreateSquareImagesTask.new(options)
    task.execute
  end

  desc "copies original large images to s3 if doesn't exist"
  task ensure_large_s3: :environment do
    offset = (ENV['OFFSET'] or 0).to_i

    bucket = S3.s3.buckets[Lilsis::Application.config.aws_s3_bucket]

    # existing = open('s3-large-files.txt').read.split("\n")
    existing = `AWS_ACCESS_KEY_ID=#{Lilsis::Application.config.aws_key} AWS_SECRET_ACCESS_KEY=#{Lilsis::Application.config.aws_secret} aws s3 ls s3://pai-littlesis/images/large/ | tr -s ' ' | cut -d ' ' -f 4`.split("\n").drop(1)
    print "found #{existing.count} existing large s3 images...\n"
    
    images = Image.joins(:entity).where(is_featured: true, entity: { is_deleted: false }).where.not(url: nil).offset(offset)
    print "ensuring large s3 image for #{images.count} images with source urls...\n"

    results = []

    images.each_with_index do |image, i|
      n = i + offset

      if existing.include?(image.filename)
        print "[#{n}] * large s3 image already exists for #{image.filename}\n"
        next
      end

      if result = image.ensure_large_s3
        if result == :exists
          print "[#{n}] * large s3 image already exists for #{image.filename}\n"
          binding.pry
        else
          binding.pry if existing.include?(image.filename)
          print "[#{n}] + created large s3 image: #{image.s3_url('large')}\n"
        end
      else
        print "[#{n}] - no large s3 image found and original (#{image.url}) doesn't exist for #{image.filename}\n"
      end

      results << result
    end

    binding.pry
    print "\n"
  end

  desc "removes s3 images that don't belong to any entity"
  task remove_s3_orphans: :environment do
    offset = (ENV['OFFSET'] or 0).to_i
    bucket = S3.s3.buckets[Lilsis::Application.config.aws_s3_bucket]

    s3_filenames = `AWS_ACCESS_KEY_ID=#{Lilsis::Application.config.aws_key} AWS_SECRET_ACCESS_KEY=#{Lilsis::Application.config.aws_secret} aws s3 ls s3://#{Lilsis::Application.config.aws_s3_bucket}/images/profile/ | tr -s ' ' | cut -d ' ' -f 4`.split("\n").drop(1)
    print "found #{s3_urls.count} existing s3 profile images...\n"
    local_filenames = Image.all.pluck(:filename)

    s3_filenames.each_with_index do |filename, i|
      unless local_filenames.include?(filename)
        bucket.objects["images/profile/#{filename}"].delete
      end
    end
  end

  desc "creates face grid from list of entities"
  task create_face_grid: :environment do
    require '/Users/matthew/code/image-processing/composite/eyes_finder.rb'

    ids_file = ENV['IDS_FILE']
    list_id = ENV['LIST_ID']
    limit = (ENV['LIMIT'] or 100).to_i
    face_size = (ENV['FACE_SIZE'] or 50).to_i
    dimensions = ENV['DIMENSIONS'] or "20x20"

    if ids_file
      ids = File.readlines(ids_file).map(&:to_i)
      entities = Entity.find(ids).sort_by { |e| ids.index(e.id) }
      list_id = Time.now.to_i
    else
      list = List.find(list_id.to_i)
      entities = list.entities
    end

    count = 0
    completed = []

    face_paths = entities.map do |entity|
      next if count >= limit
      next unless image = entity.featured_image
      image.download_large_to_tmp or image.download_profile_to_tmp
      finder = EyesFinder.new(image.tmp_path, face_size)
      unless finder.is_loaded
        File.delete(image.tmp_path)
        next
      end
      eyes = finder.find_eyes
      unless rect = finder.face_rect
        File.delete(image.tmp_path)
        next
      end
      x = rect.x
      y = rect.y
      w = rect.width
      h = rect.height
      if w > h
        x += (w-h)/2
        w = h
      else
        y += (h-w)/2
        h = w
      end
      sub = [w, h].min/3
      x += sub/2
      y += sub/2
      w -= sub
      h -= sub
      img = MiniMagick::Image.open(image.tmp_path)
      img.crop("#{w}x#{h}+#{x}+#{y}")
      img.resize("100x100")
      name = File.basename(image.tmp_path).split('.')[0]
      face_path = Rails.root.join("tmp", "faces", "face-" + name + ".jpg").to_s
      img.write(face_path)
      File.delete(image.tmp_path)
      count += 1
      print "[#{count}/#{limit}] found face of #{entity.name}\n"
      completed << entity.id
      face_path
    end

    outfile = Rails.root.join("data", "list-#{list_id}-face-grid.jpg")
    command = "montage #{Rails.root.join("tmp", "faces", "face-*.jpg")} -geometry 100x100+0+0 -tile #{dimensions} #{outfile}"
    print "#{command}\n"
    `#{command}`
    binding.pry
  end

  desc "creates street view images for list of entities"
  task create_street_views: :environment do
    list_id = ENV['LIST_ID'].to_i
    List.find(list_id).entities_with_couples.each_with_index do |e, i|
      next unless e.addresses.count == 1
      a = e.addresses.first
      next unless a.street1 
      next if e.images.find { |i| i.caption and i.caption.match(/street view:/) }
      print "#{i+1} finding street view image for #{e.name}\n"
      if image = a.add_street_view_image_to_entity
        print "+ #{a.to_s}\n"
        print "+ #{image.url}\n"
      end
    end
  end
end
