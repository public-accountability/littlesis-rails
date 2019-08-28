# frozen_string_literal: true

# Used to generate params for owners queue flow
# initialize with id of a Iapd Advisor (IapdDatum class)
class IapdQueueService
  attr_reader :queue, :queue_meta

  def initialize(advisor_id)
    @advisor = IapdDatum.find(advisor_id)

    @queue = @advisor
               .related_unmatched
               .where(primary_ext: :person)
               .pluck(:id)

    @queue_meta = { external_dataset_id: @advisor.id,
                    crd_number: @advisor.iapd_data.crd_number,
                    name: @advisor.iapd_data.name }

    freeze
  end
end
