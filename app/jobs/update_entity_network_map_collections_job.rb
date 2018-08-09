# frozen_string_literal: true

class UpdateEntityNetworkMapCollectionsJob < ApplicationJob
  queue_as :default

  def perform(network_map_id, **args)
    %i[remove add].each do |action|
      args.fetch(action, []).each do |entity_id|
        EntityNetworkMapCollection.new(entity_id).public_send(action, network_map_id).save
      end
    end
  end
end
