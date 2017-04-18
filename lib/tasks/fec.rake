require Rails.root.join('lib', 'task-helpers', 'fec_links.rb')

namespace :fec do
  desc 'Fixes the fec links'
  task update: :environment do
    FecLinks.update
  end

  desc 'Reports how many fec links contain the problematic url'
  task verify: :environment do
    FecLinks.verify
  end

  desc 'change ref type on all FEC filing references'
  task fix_fec_filing_ref_type: :environment do
    sql1 = "UPDATE reference SET ref_type = 2 WHERE name like 'FEC Filing%'"
    ActiveRecord::Base.connection.execute(sql1)
    sql2 = "UPDATE reference SET ref_type = 2 WHERE name = 'FEC contribution search'"
    ActiveRecord::Base.connection.execute(sql2)
  end
end
