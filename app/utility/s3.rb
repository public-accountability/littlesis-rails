# frozen_string_literal: true

class S3
  BUCKET = Lilsis::Application.config.aws_s3_bucket.dup.freeze

  def self.url(path)
    base_url + path
  end

  def self.base_url
    config = Lilsis::Application.config
    config.aws_s3_base + '/' + config.aws_s3_bucket
  end

  def self.s3
    @s3 ||= Aws::S3::Resource.new(
      region: Lilsis::Application.config.aws_region,
      access_key_id: Lilsis::Application.config.aws_key,
      secret_access_key: Lilsis::Application.config.aws_secret
    )
  end

  def self.file_exists?(path, bucket = Lilsis::Application.config.aws_s3_bucket)
    s3.bucket(bucket).object(path).exists?
  end

  def self.upload_file(bucket, remote_path, local_path, check_first = true)
    object = s3.bucket(bucket).object(remote_path.gsub(/^\//, ''))
    return true if check_first && object.exists?

    begin
      object.put s3_options(local_path)
    rescue => e
      Rails.logger.info "Failed to upload file: #{local_path}"
      Rails.logger.debug e
      return false
    end

    true
  end

  private_class_method def self.s3_options(local_path)
    options = { body: IO.read(Pathname.new(local_path)), acl: 'public-read' }
    options.store(:content_type, 'image/svg+xml') if local_path.slice(-3, 3).casecmp?('svg')
    options
  end
end
