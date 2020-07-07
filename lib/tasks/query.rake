# frozen_string_literal: true

require 'csv'

namespace :query do
  desc 'Saves Os Donations for each member of a list as csv'
  task :donations_from_list, [:list_id] => :environment do |_, args|
    list_id = args[:list_id]
    file_path = Rails.root.join('data', "list_#{list_id}_os_donations_#{Utility.today_str}.csv")
    donations = List
                  .find(list_id)
                  .entities
                  .collect { |e| e.contribution_info.map(&:attributes) }
                  .flatten

    utility.save_hash_array_to_csv(file_path, donations)

    puts "#{donations.count} donations saved to #{file_path}"
  end

  desc 'Saves NY State donations from list'
  task :ny_donations_from_list, [:list_id] => :environment do |_, args|
    list_id = args[:list_id]
    file_path = Rails.root.join('data', "list_#{list_id}_ny_donations_#{Utility.today_str}.csv")

    get_ny_donations = proc do |e|
      NyMatch.where(donor_id: e.id).map do |match|
        recipient_entity = match.ny_filer_entity&.entity
        recipient_name = recipient_entity&.name
        recipient_id = recipient_entity&.id
        match.info.merge(:donor_entity_id => e.id, :recipient_name => recipient_name, :recipient_entity_id => recipient_id)
      end
    end

    donations = List.find(list_id).entities.collect(&get_ny_donations).flatten

    sorted_donations = donations.sort_by { |h| [h[:entity_id], -h[:amount]] }

    Utility.save_hash_array_to_csv(file_path, sorted_donations)
  end

  desc 'get board members for given list'
  task :board_members_from_list, [:list_id] => :environment do |_, args|
    list_id = args[:list_id]
    file_path = Rails.root.join('data', "list_#{list_id}_board_members_#{Utility.today_str}.csv")
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

    Utility.save_hash_array_to_csv(file_path, board_members)
  end

  desc 'Saves a csv of donations to provided NYS Filers by id'
  task :nys_donations_to_filers => [:environment] do |_, args|
    abort 'no nys filer ids provided' if args.extras.size.zero?
    file_name = "donations_to_#{args.extras.join('_')}_#{Utility.today_str}.csv"
    file_path = Rails.root.join 'data', file_name

    filer_names = NyFiler
                    .where(filer_id: args.extras)
                    .each_with_object({}) { |filer, h| h.store(filer.filer_id, filer.name) }
    donations = NyDisclosure.where(filer_id: args.extras).map do |nyd|
      nyd.attributes
        .except('delta', 'updated_at', 'created_at')
        .merge('filer_name' => filer_names.fetch(nyd.attributes.fetch('filer_id')))
    end

    Utility.save_hash_array_to_csv(file_path, donations)
  end

  desc "save CSV of an Entity's Federal Contributions"
  task :os_donations_for_entity, [:entity] => :environment do |_, args|
    file_path = Rails.root.join('data', "os_donations_for_#{args[:entity]}_#{Utility.today_str}.csv")
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

    Utility.save_hash_array_to_csv(file_path, data)
  end

  desc 'save CSV of an all federal contributions to trump by state'
  task :trump_donors_by_state, [:state] => :environment do |_, args|
    file_path = Rails.root.join('data', "os_donations_for_state_#{args[:state]}_#{Utility.today_str}.csv")

    trump_committees = {
      'N00023864' => 'Donald J Trump for President',
      'C00618876' => 'Rebuilding America Now',
      'C00618389' => 'Trump Victory',
      'C00618371' => 'Trump Make America Great Again Committee',
      'C00608489' => 'Great America PAC',
      'C00616078' => 'Get Our Jobs Back',
      'C00580373' => 'Make America Great Again',
      'C00580100' => 'Donald J. Trump for President, Inc'
    }

    trump_committees_sql = Entity.sqlize_array(trump_committees.keys)

    CSV.open(file_path, 'wb') do |csv|
      csv << (OsDonation.attribute_names + Array('committee_name'))

      OsDonation
        .where("recipid in #{trump_committees_sql} AND state = '#{args[:state].upcase}'")
        .order('amount DESC')
        .each { |d| csv << (d.attributes.values + Array(trump_committees.fetch(d.recipid))) }
    end

    puts "Saved to #{file_path}"
  end

  desc 'Most connected entities from a list'
  task :connected_entities_from_list, [:list_id] => :environment do |t, args|
    file_path = Rails.root.join('data', "connected_entities_for_list_#{args[:list_id]}_#{Utility.today_str}.csv")
    entity_ids = List.find(args[:list_id]).entities.map(&:id).uniq

    sql = <<-SQL
    SELECT entity.name, sub.* FROM (
           SELECT entity2_id,
                  count(link.id) as rel_count,
                  group_concat( concat(entity.name, ' (', link.entity1_id, ')') SEPARATOR ', ') as connected_entities
           FROM link
           LEFT JOIN entity ON entity.id = link.entity1_id
           WHERE entity1_id in #{Entity.sqlize_array(entity_ids)}
           GROUP BY entity2_id
           ORDER BY rel_count desc
    ) as sub
    LEFT JOIN entity ON entity.id = sub.entity2_id
    SQL

    result = []
    ApplicationRecord.connection.execute(sql).each(:as => :hash) { |h| result << h }

    Utility.save_hash_array_to_csv(file_path, result)
  end
end
