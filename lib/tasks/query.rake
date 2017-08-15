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

  desc "Download donations to NYS Filer"
  task :nys_donations_to_filer, [:filer] => :environment do |t, args|
    filer = args[:filer]
    file_path = Rails.root.join('data', "donations_to_#{filer}_#{Date.today}.csv")

    donations = NyDisclosure.where(filer_id: filer).map do |nyd|
      nyd.attributes.except('delta', 'updated_at', 'created_at')
    end

    CSV.open(file_path, "wb") do |csv|
      csv << donations.first.keys
      donations.each do |hash|
        csv << hash.values
      end
    end
  end

  desc "save CSV of an Entity's Federal Contributions"
  task :os_donations_for_entity, [:entity] => :environment do |t, args|
    file_path = Rails.root.join('data', "os_donations_for_#{args[:entity]}_#{Date.today}.csv")
    data = Entity.find(args[:entity]).contribution_info.map do |contribution|
      json = contribution.as_json
      cand = OsCandidate.find_by_crp_id(json['recipid'])
      cmte = OsCommittee.find_by_cmte_id(json['recipid'])
      json['candidate_name'] = nil
      json['candidate_party'] = nil
      json['distid_runfo'] = nil
      if cand
        json['candidate_name'] = cand.name
        json['candidate_party'] = cand.party
        json['distid_runfo'] = cand.distid_runfor
      end
      json['committee_name'] = cmte.name if cmte
      json
    end

    CSV.open(file_path, "wb") do |csv|
      csv << data.first.keys
      data.each { |hash| csv << hash.values }
    end
  end
end
