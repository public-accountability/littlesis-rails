namespace :images do
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
