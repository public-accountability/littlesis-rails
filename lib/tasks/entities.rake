namespace :entities do
  desc "update link counts for all entities"
  task update_link_counts: :environment do |task|
    require 'benchmark'

    print "updating link count for #{Entity.all.count} entities...\n"

    db = ApplicationRecord.connection
    counts = db.execute("SELECT entity1_id, COUNT(id) AS count FROM link GROUP BY entity1_id")
    counts.each do |id, count|
      db.execute("UPDATE entity SET link_count = #{count} WHERE id = #{id}")
    end

    print "\n"
  end
end
