require 'csv'

namespace :query do
  desc "Saves Os Donations for each member of a list as csv"
  task :donations_from_list, [:list_id] =>  :environment do |t, args|
    list_id = args[:list_id]
    file_path = Rails.root.join('data', "list_#{list_id}_os_donations_#{Date.today}.csv")
    donations = List.find(list_id).entities.collect { |e| e.contribution_info.map(&:attributes) }.flatten

    CSV.open(file_path, "wb") do |csv|
      csv << donations.first.keys 
      donations.each do |hash|
        csv << hash.values
      end
    end

    puts "#{donations.count} donations saved to #{file_path}"
  end
end
