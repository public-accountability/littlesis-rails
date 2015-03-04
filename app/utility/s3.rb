class S3
  def self.url(path)
    base_url + path
  end
  
  def self.base_url
    config = Lilsis::Application.config
    config.aws_s3_base + "/" + config.aws_s3_bucket
  end
  
  def self.s3
    @s3 ||= AWS::S3.new(
      access_key_id: Lilsis::Application.config.aws_key,
      secret_access_key: Lilsis::Application.config.aws_secret
    )
  end

  def self.upload_file(bucket, remote_path, local_path, check_first=true)
    bucket = s3.buckets[bucket]
    object = bucket.objects[remote_path.gsub(/^\//, '')]

    if check_first && object.exists?
      return true
    end

    begin
      object.write(Pathname.new(local_path), { acl: :public_read })
    rescue
      return false
    end

    true
  end
end