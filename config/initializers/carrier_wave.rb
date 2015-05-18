unless Rails.env.development?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Lilsis::Application.config.aws_key,
      :aws_secret_access_key  => Lilsis::Application.config.aws_secret,
    }
    config.fog_directory  = Lilsis::Application.config.aws_s3_bucket
  end
end
