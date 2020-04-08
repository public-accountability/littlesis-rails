# frozen_string_literal: true

# Sets all MergeRequest as denied
# Used after an Entity has been deleted
class PendingEntityRequestResolver
  def initialize(entity)
    @entity = Entity.entity_for(entity)
    @user = User.system_user
  end

  def run
    merge_requests.each do |request|
      request.denied_by!(@user)
    end
  end

  private

  def merge_requests
    MergeRequest
      .pending
      .where(source_id: @entity.id)
      .or(MergeRequest.where(dest_id: @entity.id))
  end
end
