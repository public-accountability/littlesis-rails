namespace :maintenance do
  desc "flip donation direction for a given entity"
  task flip_donations: :environment do
    id = ENV['LILSIS_ENTITY_ID']
    e = Entity.find(id)

    rels = Relationship.where(category_id: 5, entity1_id: id)

    rels.each do |r|
      r.entity = r.related
      r.related = e
      r.save

      r.links.each do |l|
        l.is_reverse = !l.is_reverse
        l.save
      end
    end
  end

  desc "flip ownership direction for a given entity"
  task flip_ownership: :environment do
    id = ENV['LILSIS_ENTITY_ID']
    e = Entity.find(id)

    rels = Relationship.where(category_id: 10, entity2_id: id)

    rels.each do |r|
      r.related = r.entity
      r.entity = e
      r.save

      r.links.each do |l|
        l.is_reverse = !l.is_reverse
        l.save
      end
    end
  end
end