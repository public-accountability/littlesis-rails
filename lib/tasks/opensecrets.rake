namespace :opensecrets do
  desc "import individual contribution data"
  task :import_indivs, [:filepath] =>  :environment do |t, args| 
    OsImporter.import_indivs args[:filepath]
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
