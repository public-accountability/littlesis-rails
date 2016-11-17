namespace :opensecrets do
  desc "import individual contribution data"
  task :import_indivs, [:filepath] =>  :environment do |t, args| 
    start = Time.now
    OsImporter.import_indivs args[:filepath]
    execution_time = Time.now - start
    printf("** OsImporter took %d seconds **\n", execution_time)
    printf("** There are currently %s donations in the db **\n", OsDonation.count)
  end
  
  desc "import congress"
  task import_congress: :environment do 
    importer = OsCongressImporter.new Rails.root.join('data', 'members114.csv') , Rails.root.join('data', 'members114_ids.csv') 
    importer.start
  end

  desc "import candidates"
  task import_candidates: :environment do 
    ###### Encoding details ##################################################
    # Before running, issue this db command:
    # ALTER TABLE `littlesis`.`os_candidates` CONVERT TO CHARACTER SET utf8; 
    ########################################################################### 
    Dir.foreach( Rails.root.join('data', 'cands') ) do |filename|
      next if filename == '.' or filename == '..'
      printf("Processing: %s \n", filename)
      OsCandidateImporter.start Rails.root.join('data', 'cands', filename)
    end
    printf("** There are currently %s candidates in the db **\n", OsCandidate.count)
  end

  desc "import committees"
  task import_committees: :environment do
    ###### Encoding details ##################################################
    # Before running, issue this db command:
    # ALTER TABLE `littlesis`.`os_committees` CONVERT TO CHARACTER SET utf8; 
    ########################################################################### 
    start = Time.now
    original_committees_count = OsCommittee.count
    Dir.foreach( Rails.root.join('data', 'cmtes') ) do |filename|
      next if filename == '.' or filename == '..'
      printf("Processing: %s \n", filename)
      OsCommitteeImporter.start Rails.root.join('data', 'cmtes', filename)
    end
    execution_time = Time.now - start
    printf("** Import Committees took %d seconds **\n", execution_time)
    printf("** Added %s new committees **\n", (OsCommittee.count - original_committees_count) )
    printf("** There are currently %s committees in the db **\n", OsCommittee.count)
  end

  desc "Find missing candidates"
  task missing_candidates: :environment do 
    sql = "SELECT DISTINCT recipid from os_donations where recipid like 'N%'"
    recipids = ActiveRecord::Base.connection.execute(sql)
    
    found = 0
    not_found = 0
    found_in_os = 0
    
    recipids.each do |recpid|
      id = recpid[0]
      elected = ElectedRepresentative.includes(:entity).find_by(crp_id: id, entity: {is_deleted: false})
      unless elected.nil?
        found += 1
        next
      end
      candidate = PoliticalCandidate.includes(:entity).find_by(crp_id: id, entity: {is_deleted: false})
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
    printf("Percent found %s  \n", ( ((found + found_in_os) / total) * 100) )
  end
  
  desc "Find Os_Matches without recipients"
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

  desc "How many OsMatches are missing relationships"
  task missing_relationships: :environment do 
    printf("There are %s os_matches  with NULL relationships\n", OsMatch.where('relationship_id is null').count)
  end

  desc "Find missing recip_ids and update/creates relationships"
  task rematch: :environment do 
    OsMatch.where('relationship_id is null').each do |match|
       match.set_recipient
       match.update_donation_relationship
       match.create_reference
    end
  end
  
  desc "Match legacy Os Donations"
  task legacy_matcher: :environment do
    OsMatch.skip_callback(:create, :after, :post_process)
    
    start = Time.now
    sql = "select distinct fec_filing.relationship_id from fec_filing 
           inner join relationship on relationship.id = fec_filing.relationship_id
           where relationship.is_deleted = 0"
    
    # smaller query for testing
    test_sql = "select distinct fec_filing.relationship_id from fec_filing 
           inner join relationship on relationship.id = fec_filing.relationship_id
           where fec_filing.crp_cycle = 2008 and relationship.is_deleted = 0
           limit 3000"
    
    ids = ActiveRecord::Base.connection.execute(sql)
        
    ids.each do |i| 
       relationship_id = i[0]
       # printf("\n processing relationship: %s\n", relationship_id)
       matcher = OsLegacyMatcher.new relationship_id
       matcher.match_all
    end
    
    execution_time = Time.now - start
    printf("\n** OsLegacyMatcher took %d seconds **\n", execution_time)
    printf("** There are currently %s matched donations **\n", OsMatch.count)
    OsMatch.set_callback(:create, :after, :post_process)
  end
  
  desc "import addresses from matched opensecrets donations"
  task import_addresses: :environment do
    if ENV['ENTITY_ID']
      entities = Entity.where(id: ENV['ENTITY_ID'])
    elsif ENV['LIST_ID']
      entities = List.find(ENV['ENTITY_ID']).entities.people
    elsif ENV['LIMIT']
      entities = Entity.people.limit(ENV['LIMIT'])
    else
      print "you must set an ENTITY_ID, LIST_ID, or LIMIT environment variable\n"
      exit
    end

    # limit to entities that have matched transactions
    entities = entities.includes(:os_entity_transactions).where(os_entity_transaction: { is_verified: true })

    # limit to entities that don't have addresses
    entities = entities.includes(:addresses).where(address: { entity_id: nil })

    count = 0

    entities.each do |entity|
      importer = OpensecretsAddressImporter.new(entity)
      print "#{importer.addresses.count} (#{importer.incoming.count}) addresses found for #{entity.name} (#{entity.id})\n"
      count += 1 if importer.addresses.count > 0
      # binding.pry if importer.addresses.count == 0 and importer.incoming.count > 0
    end

    print "addresses found for #{count} of #{entities.count} entities\n"
  end
end
