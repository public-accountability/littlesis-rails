CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => Rails.env.development? ? '' : Lilsis::Application.config.aws_key,
    :aws_secret_access_key  => Rails.env.development? ? '' : Lilsis::Application.config.aws_secret,
  }
  config.fog_directory  = Lilsis::Application.config.aws_s3_bucket
end
