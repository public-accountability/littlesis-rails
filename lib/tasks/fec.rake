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
end
