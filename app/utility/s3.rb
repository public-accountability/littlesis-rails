# frozen_string_literal: true

class S3
  BUCKET = Lilsis::Application.config.aws_s3_bucket.dup.freeze
  CACHE_CONTROL = 'public, max-age=2592000' # 30 days

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

  def self.upload_file(remote_path:, local_path:, bucket: S3::BUCKET, check_first: true)
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

  def self.public?(s3_object)
    TypeCheck.check s3_object, Aws::S3::Object
    return false unless s3_object.exists?
    s3_object.acl.grants.each do |grant|
      if grant.grantee.type == 'Group' && grant.grantee.uri.include?('global/AllUsers') && grant.permission == 'READ'
        return true
      end
    end
    return false
  end

  def self.make_public_and_set_cache_headers(s3_object)
    raise NotImplementedError
  end

  private_class_method def self.s3_options(local_path)
    options = { body: IO.read(Pathname.new(local_path)),
                acl: 'public-read',
                cache_control: CACHE_CONTROL }
    options.store(:content_type, 'image/svg+xml') if local_path.slice(-3, 3).casecmp?('svg')
    options
  end
end
