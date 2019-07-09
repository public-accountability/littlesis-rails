# frozen_string_literal: true

namespace :iapd do
  desc 'recreate the iapd owners queue'
  task update_owners_queue: :environment do
    puts 'updating the owners queue'
  end

  desc 'recreate the iapd adivsors queue'
  task update_advisors_queue: :environment do
    puts 'updating the advisors queue'
  end
end
