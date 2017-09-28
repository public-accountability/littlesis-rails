module Interlocks
  # extend ActiveSupport::Concern
  def interlocks(page = 1)
    # TODO: create position_scope for Link
    org_ids = connecting_ids(rel_cat_id)
    people_and_org_ids = paginate(page,
                                  Entity::PER_PAGE,
                                  connected_id_hashes_for(org_ids, rel_cat_id))

    entities_by_id = Entity.lookup_table_for(collapse(people_and_org_ids))

    people_and_org_ids.map do |connected_id_hash|
      {
        "person" => entities_by_id.fetch(connected_id_hash[:connected_id]),
        "orgs" => connected_id_hash[:connecting_ids].map { |id| entities_by_id.fetch(id) }
      }
    end
  end

  private

  def rel_cat_id
    Relationship::POSITION_CATEGORY
  end

  def connecting_ids(cat_id)
    links
      .where(entity1_id: id,
             category_id: cat_id,
             is_reverse: false)
      .pluck(:entity2_id)
  end

  # type ConnectedIdHash = { connected_id   => Integer,
  #                          connecting_ids => [Integer] }
  # ---
  # [Integer], Integer -> [ConnectedIdHash]
  def connected_id_hashes_for(connecting_ids, rel_category_id)
    Link
      .where(entity2_id: connecting_ids,
             category_id: rel_category_id,
             is_reverse: false)
      .to_a
      .group_by(&:entity1_id)
      .tap { |grouped_ids| grouped_ids.delete(id) }
      .map { |connected_id, links| { connected_id: connected_id,
                                     connecting_ids: links.map(&:entity2_id).uniq } }
      .sort { |a, b| b[:connecting_ids].count <=> a[:connecting_ids].count }
  end

  # Array(ConnectedIdHash) => [Integer]
  def collapse(connected_id_hashes)
    connected_id_hashes.map { |x| [x[:connected_id], x[:connecting_ids]] }.flatten.uniq
  end
end
