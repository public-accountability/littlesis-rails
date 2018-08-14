# frozen_string_literal: true
namespace :images do
  desc 'Sets Cache Headers and ensures all images are public'
  task public_cache: :environment do
    stats = Struct.new(:count, :missing).new(0, 0)

    Image.find_each do |img|
      if img.has_square
        image_types = Image::IMAGE_TYPES.dup.tap { |t| t << :square }
      else
        image_types = Image::IMAGE_TYPES
      end

      image_types.each do |type|
        stats.count += 1
        obj = S3.s3.bucket(S3::BUCKET).object(Image.s3_path(img.filename, type))
        if obj.exists?
          S3.make_public_and_set_cache_headers(obj)
        else
          stats.missing += 1
        end
      end
      pp stats if (stats.count % 1_000).zero?
    end
  end

  desc "removes s3 images that don't belong to any entity"
  task remove_s3_orphans: :environment do
    offset = (ENV['OFFSET'] or 0).to_i
    bucket = S3.s3.buckets[Lilsis::Application.config.aws_s3_bucket]

    type = (ENV['TYPE'] or 'profile')
    s3_filenames = `AWS_ACCESS_KEY_ID=#{Lilsis::Application.config.aws_key} AWS_SECRET_ACCESS_KEY=#{Lilsis::Application.config.aws_secret} aws s3 ls s3://#{Lilsis::Application.config.aws_s3_bucket}/images/#{type}/ | tr -s ' ' | cut -d ' ' -f 4`.split("\n").drop(1)
    print "found #{s3_filenames.count} existing s3 #{type} images...\n"
    local_filenames = Image.unscoped.all.pluck(:filename).concat(SfGuardUserProfile.unscoped.all.pluck(:filename)).uniq

    s3_filenames.each_with_index do |filename, i|
      if local_filenames.include?(filename)
        print "kept #{filename}\n"
      else
        bucket.objects["images/#{type}/#{filename}"].delete
        print "removed #{filename}\n"
      end
    end
  end
end
