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
  
  desc "get board members for given list"
  task :board_members_from_list, [:list_id] =>  :environment do |t, args|
    list_id = args[:list_id]
    file_path = Rails.root.join('data', "list_#{list_id}_board_members_#{Date.today}.csv")
    board_members = []
    List.find(list_id).entities.each do |entity|
      Relationship.where(entity2_id: entity.id, category_id: 1).each do |rel|
        if rel.is_current && rel.is_board
          entity_email = rel.entity.emails.blank? ? "" : rel.entity.emails.map(&:address).join('|')
          info = { 
            'company' => entity.name,
            'person_name' => rel.entity.name,
            'email' => entity_email
          }
          board_members << info
        end
      end
    end
    
    CSV.open(file_path, "wb") do |csv|
      csv << board_members.first.keys
      board_members.each  { |hash| csv << hash.values } 
    end
  end

end
