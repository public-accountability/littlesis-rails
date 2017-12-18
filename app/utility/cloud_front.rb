class CloudFront
  def initialize
    @cf ||= Aws::CloudFront::Client.new(
      region: Lilsis::Application.config.aws_region,
      access_key_id: Lilsis::Application.config.aws_key,
      secret_access_key: Lilsis::Application.config.aws_secret
    )
  end

  def invalidate(paths)
    config = Lilsis::Application.config

    if config.cloudfront_distribtion_id
      @cf.create_invalidation(
        distribution_id: config.cloudfront_distribtion_id,
        invalidation_batch: {
          paths: {
            quantity: paths.count,
            items: paths
          },
          caller_reference: Time.now.to_i.to_s
        }
      )
    end
  end
end
