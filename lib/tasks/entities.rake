# frozen_string_literal: true

namespace :entities do
  desc "update link counts for all entities"
  task update_link_counts: :environment do
    sql = <<~SQL.squish
      SELECT entities.id as id, entities.link_count as entities_link_count, link_counts.link_count as link_link_count
      FROM  (SELECT entity1_id, COUNT(id) AS link_count
           FROM links
           GROUP BY entity1_id) AS link_counts
      INNER JOIN entities ON entities.id = link_counts.entity1_id AND entities.is_deleted = false
      WHERE entities.link_count <> link_counts.link_count
    SQL

    entities_to_update = ApplicationRecord.execute_one("SELECT COUNT(*) FROM (#{sql}) as x")

    Rails.logger.info "Updating the entities.link_count for #{entities_to_update} entities"

    ApplicationRecord.connection.execute(sql).each do |row|
      Entity.find(row['id']).update_columns(:link_count => row['link_link_count'])
    end

    Rails.logger.info "Finished updating entities.link_count"
  end
end
