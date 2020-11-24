# frozen_string_literal: true

class NewRecordMetrics
  attr_reader :entity, :relationship, :list, :network_map

  def initialize(start_time, end_time)
    @start_time = start_time
    @end_time = end_time

    @entity = new_record_count(Entity)
    @relationship = new_record_count(Relationship)
    @list = new_record_count(List)
    @network_map = new_record_count(NetworkMap)
  end

  private

  def new_record_count(model)
    model.where(created_at: @start_time..@end_time).count
  end
end
