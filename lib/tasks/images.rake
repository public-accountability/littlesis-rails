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

  desc "removes s3 images that don't belond to any entity"
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
end
