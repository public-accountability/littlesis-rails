class CloudFront
  def initialize
    config = Lilsis::Application.config

    @cf ||= AWS::CloudFront.new(
      access_key_id: Lilsis::Application.config.aws_key,
      secret_access_key: Lilsis::Application.config.aws_secret
    )
  end

  def invalidate(paths)
    config = Lilsis::Application.config

    if config.cloudfront_distribtion_id
      ref = Time.now.to_i.to_s

      @cf.client.create_invalidation({
        distribution_id: config.cloudfront_distribtion_id,
        invalidation_batch: {
          paths: {
            quantity: paths.count,
            items: paths
          },
          caller_reference: ref
        }
      })
    end
  end
end