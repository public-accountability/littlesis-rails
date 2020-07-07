# frozen_string_literal: true

namespace :opensecrets do
  desc 'import individual contribution data'
  task :import_indivs, [:filepath] => :environment do |_t, args|
    start = Time.current
    OsImporter.import_indivs args[:filepath]
    execution_time = Time.current - start
    printf("** OsImporter took %d seconds **\n", execution_time)
    printf("** There are currently %s donations in the db **\n", OsDonation.count)
  end

  desc 'import congress'
  task import_congress: :environment do
    importer = OsCongressImporter.new Rails.root.join('data', 'members114.csv') , Rails.root.join('data', 'members114_ids.csv')
    importer.start
  end

  ###### Encoding details ##################################################
  # Before running, issue this db command:
  # ALTER TABLE `littlesis`.`os_candidates` CONVERT TO CHARACTER SET utf8;
  ###########################################################################
  desc 'import candidates'
  task :import_candidates, [:filepath] => :environment do |_t, args|
    if Dir.exist?(args[:filepath])
      Dir.chdir(args[:filepath]) do
        Dir["*"].each do |x|
          filename = File.join(Dir.pwd, x)
          ColorPrinter.print_blue "Processing: #{filename}"
          OsCandidateImporter.start(filename)
        end
      end
    else
      ColorPrinter.print_blue "Processing: #{args[:filepath]}"
      OsCandidateImporter.start(args[:filepath])
    end
    printf("** There are currently %s candidates in the db **\n", OsCandidate.count)
  end

  ###### Encoding details ##################################################
  # Before running, issue this db command:
  # ALTER TABLE `littlesis`.`os_committees` CONVERT TO CHARACTER SET utf8;
  ###########################################################################
  desc 'import committees'
  task :import_committees, [:filepath] => :environment do |_t, args|
    start = Time.now
    original_committees_count = OsCommittee.count
    if Dir.exist?(args[:filepath])
      Dir.chdir(args[:filepath]) do
        Dir["*"].each do |x|
          filename = File.join(Dir.pwd, x)
          ColorPrinter.print_blue "Processing: #{filename}"
          OsCommitteeImporter.start filename
        end
      end
    else
      ColorPrinter.print_blue "Processing: #{args[:filepath]}"
      OsCommitteeImporter.start args[:filepath]
    end
    execution_time = Time.now - start
    printf("** Import Committees took %d seconds **\n", execution_time)
    printf("** Added %s new committees **\n", (OsCommittee.count - original_committees_count))
    printf("** There are currently %s committees in the db **\n", OsCommittee.count)
  end

  desc 'Find missing candidates'
  task missing_candidates: :environment do
    sql = "SELECT DISTINCT recipid from os_donations where recipid like 'N%'"
    recipids = ApplicationRecord.connection.execute(sql)

    found = 0
    not_found = 0
    found_in_os = 0

    recipids.each do |recpid|
      id = recpid[0]
      elected = ElectedRepresentative.includes(:entity)
                  .find_by(crp_id: id, entity: { is_deleted: false })

      unless elected.nil?
        found += 1
        next
      end

      candidate = PoliticalCandidate.includes(:entity)
                    .find_by(crp_id: id, entity: { is_deleted: false })

      unless candidate.nil?
        found += 1
        next
      end

      os_candidate = OsCandidate.find_by(crp_id: id)
      if os_candidate.nil?
        printf("Could not find candidate in OsCandidate with id: %s \n", id)
        not_found += 1
      else
        found_in_os += 1
        printf("Found candidate in OsCandidate: %s, %s \n", os_candidate.name, os_candidate.id)
      end
    end

    total = (found + not_found + found_in_os)
    printf("Found: %s \n", found)
    printf("NOT Found: %s \n", not_found)
    printf("Found in OsCandidate: %s \n", found_in_os)
    printf("total: %s \n", total)
    printf("Percent found %s  \n", ((found + found_in_os) / total) * 100)
  end

  desc 'Find Os_Matches without recipients'
  task os_matches_without_recip: :environment do
    OsMatch.where('recip_id is null').each do |match|
      recipid = match.os_donation.recipid
      cycle = match.os_donation.cycle
      cand = OsCandidate.find_by(crp_id: recipid, cycle: cycle)
      if cand.nil?
        # printf("Could not find a candidate for : %s\n", recipid)
      else
        printf("candidate: %s (%s) - %s - %s \n", cand.name, cand.cycle, recipid, cand.distid_runfor)
      end
    end
  end

  desc 'How many OsMatches are missing relationships'
  task missing_relationships: :environment do
    printf("There are %s os_matches  with NULL relationships\n", OsMatch.where('relationship_id is null').count)
  end

  desc 'Find missing recip_ids and update/creates relationships'
  task rematch: :environment do
    OsMatch.where('relationship_id is null').each do |match|
       match.set_recipient
       match.update_donation_relationship
       match.create_reference
    end
  end
end
