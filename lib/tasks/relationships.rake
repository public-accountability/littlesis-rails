namespace :relationships do
  desc "ensure link entity ids are consistent with their relationships"
  task ensure_link_consistency: :environment do |task|
    # ensure entity1_id anad entity2_id are consistent with relationship
    links = Link.joins(:relationship).where("((link.entity1_id <> relationship.entity1_id OR link.entity2_id <> relationship.entity2_id) AND is_reverse = 0) OR ((link.entity1_id <> relationship.entity2_id OR link.entity2_id <> relationship.entity1_id) AND is_reverse = 1)")
    print "updating #{links.count} links with inconsistent entity ids...\n"
    links.each do |link|
      if link.is_reverse
        link.update(entity1_id: link.relationship.entity2_id, entity2_id: link.relationship.entity1_id)
      else
        link.update(entity1_id: link.relationship.entity1_id, entity2_id: link.relationship.entity2_id)
      end
    end

    # ensure category_id is consistent with relationship
    links = Link.joins(:relationship).where("link.category_id <> relationship.category_id")
    print "updating #{links.count} links with inconsistent category ids...\n"
    links.each do |link|
      link.update(category_id: link.relationship.category_id)
    end
  end
end
