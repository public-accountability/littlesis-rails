# frozen_string_literal: true

class S3
  BUCKET = APP_CONFIG['aws_s3_bucket'].dup.freeze
  CACHE_CONTROL = 'public, max-age=2592000' # 30 days

  def self.url(path)
    base_url + path
  end

  def self.base_url
    APP_CONFIG['aws_s3_base'] + '/' + APP_CONFIG['aws_s3_bucket']
  end

  def self.s3
    @s3 ||= Aws::S3::Resource.new(
      region: APP_CONFIG['aws_region'],
      access_key_id: APP_CONFIG['aws_key'],
      secret_access_key: APP_CONFIG['aws_secret']
    )
  end

  def self.bucket
    s3.bucket(BUCKET)
  end

  def self.file_exists?(path, bucket = BUCKET)
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

  def self.make_public(s3_object)
    s3_object.acl.put(acl: 'public-read')
  end

  # Updates S3 object metadata
  #
  # for whatever reason, the way to MODIFY an object's metadata
  # on S3 is to copy it to itself.
  #
  # Additionally, it corrects the Content-Type of the image
  # if it's missing from the metadata
  def self.make_public_and_set_cache_header(s3_object)
    return true if skip_metadata_update(s3_object)

    s3_object.copy_to(s3_object,
                      acl: 'public-read',
                      content_type: content_type_for(s3_object),
                      cache_control: CACHE_CONTROL,
                      metadata: s3_object.metadata,
                      metadata_directive: 'REPLACE')
  end

  private_class_method def self.s3_options(local_path)
    { body: IO.read(Pathname.new(local_path)),
      acl: 'public-read',
      cache_control: CACHE_CONTROL,
      content_type: determine_content_type(local_path) }
  end

  private_class_method def self.skip_metadata_update(s3_object)
    public?(s3_object) && Image::VALID_MIME_TYPES.include?(s3_object.content_type) && s3_object.cache_control == CACHE_CONTROL
  end

  private_class_method def self.content_type_for(s3_object)
    if s3_object.content_type.blank? || s3_object.content_type == 'application/octet-stream'
      determine_content_type(s3_object.key)
    else
      s3_object.content_type
    end
  end

  private_class_method def self.determine_content_type(file_path)
    ext = File.extname(file_path).tr('.', '').downcase
    case ext
    when 'svg'
      'image/svg+xml'
    when 'jpg', 'jpeg'
      'image/jpeg'
    when 'png'
      'image/png'
    when 'gif'
      'image/gif'
    end
  end
end
