# frozen_string_literal: true

namespace :iapd do
  desc 'recreate the iapd owners queue'
  task update_owners_queue: :environment do
    ColorPrinter.print_green <<~MSG
      There currently are #{IapdDatum::OWNERS_MATCHING_QUEUE.size} owners in the queue.

      Re-populating the queue...
    MSG

    IapdDatum::OWNERS_MATCHING_QUEUE.clear

    IapdDatum.advisors.matched.find_each do |advisor|
      advisor.owners.each do |owner|
        owner.add_to_matching_queue if owner.queueable?
      end
    end

    ColorPrinter.print_blue <<~MSG
      There are #{IapdDatum::OWNERS_MATCHING_QUEUE.size} owners in the queue
    MSG
  end

  desc 'recreate the iapd adivsors queue'
  task update_advisors_queue: :environment do
    puts 'updating the advisors queue'
  end
end
