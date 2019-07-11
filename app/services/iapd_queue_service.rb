# frozen_string_literal: true

# Used to generate params for owners queue flow
# initialize with id of a Iapd Advisor (IapdDatum class)
class IapdQueueService
  def initialize(advisor_id)
    @advisor = IapdDatum.find(advisor_id)
  end

  def queue
    @advisor
      .related_unmatched
      .where(primary_ext: :person)
      .pluck(:id)    
  end

  def queue_meta
    {
      external_dataset_id: @advisor.id,
      crd_number: @advisor.iapd_data.crd_number,
      name: @advisor.iapd_data.name
    }
  end
end
