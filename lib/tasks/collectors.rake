require 'csv'

namespace :collectors do
  desc "import art collectors from CSV file"
  task :import_list, [:list_id, :filename] => [:environment] do |task, args|
    list = List.find(args[:list_id])

    output_ary = [] # just in case file write fails?
    output_csv = CSV.open("data/collectors-with-ids.csv", "wb")
    output_csv << "ID,First Name,Last Name,Address,City,State,Zip,Country,Pictures,News,Profession".split(",")
    output_ary << "ID,First Name,Last Name,Address,City,State,Zip,Country,Pictures,News,Profession".split(",")

    match_ids = []
    duplicates = []

    results = {
      unknown: [],
      skipped: [],
      multiple: [],
      common_name: [],
      match: [],
      postal: [],
      postal_multiple: [],
      arts_multiple: [],
      address_multiple: [],
      arts: [],
      address: [],
      list: [],
      created: [],
      previous: []
    }

    match_types = {
      name: 0,
      alias: 0,
      postal: 0,
      arts: 0,
      address: 0,
      list: 0,
      previous: 0
    }

    address_types = {
      existing_address: 0,
      opensecrets_address: 0
    }

    common_name_types = {
      init_last: 0,
      first_last: 0,
      first_multiple: 0
    }

    images = 0
    count = 0
    total_count = previous_count = list_count = address_count = arts_count = postal_count = match_count = common_count = 0
    already_imported_ids = ListEntity.where(list_id: list.id).pluck(:entity_id)
    collector_list_ids = ListEntity.where(list_id: 330).pluck(:entity_id)
    cultural_org_ids = Entity.with_ext('Cultural').pluck(:id)
    arts_related_ids = Link.where(entity1_id: cultural_org_ids, category_id: [1, 3, 5]).pluck(:entity2_id).uniq

    CSV.foreach(args[:filename], encoding: 'windows-1251:utf-8') do |row|
      begin
        # skip label row
        if count == 0
          count = 1
          next
        end

        count += 1

        row.map! { |cell| cell.present? ? cell.gsub(/[\n\r]/, " ").gsub(/\s{2,}/, " ") : nil }
        importer = EntityNameAddressCsvImporter.new(row)
        importer.already_imported_ids(already_imported_ids)
        importer.collector_list_ids(collector_list_ids)
        importer.arts_related_ids(arts_related_ids)

        if entity = importer.import
          match_ids << entity.id if entity.id? and !importer.previous_import?
          # entity.association(:lists).add_to_target(list)            
          entity.lists << list unless entity.list_ids.include?(list.id)
          entity.last_user_id = 2
          entity.save!

          duplicates << entity if importer.matches?
          output_csv << [entity.id].concat(row)
          output_ary << [entity.id].concat(row)
        else
          output_csv << [""].concat(row)
          output_ary << [""].concat(row)
        end

        match_type = importer.match_type
        match_types[match_type] += 1 if match_type
        address_type = importer.address_type
        address_types[address_type] += 1 if address_type
        common_name_type = importer.common_name_type
        common_name_types[common_name_type] += 1 if common_name_type
        images += 1 if importer.image

        case importer.status
        when :unknown
          results[:unknown] << true
        when :created
          results[:created] << ["http://littlesis.org" + entity.legacy_url].concat(row)
        when :skipped
          results[:skipped] << row
        when :common_name
          results[:common_name] << [common_name_type, "http://littlesis.org" + importer.match.legacy_url].concat(row)
          common_count += 1
        when :matched
          if importer.previous_import?
            results[:previous] << ["http://littlesis.org" + importer.match.legacy_url].concat(row)
            previous_count += 1
          elsif importer.list_match?
            results[:list] << ["http://littlesis.org" + importer.match.legacy_url].concat(row)
            list_count += 1
          elsif importer.address_match?
            results[:address] << ["http://littlesis.org" + importer.match.legacy_url].concat(row)
            address_count += 1
          elsif importer.address_matches.count > 1
            results[:address_multiple] << [importer.raw_name].concat(importer.all_matches.map { |e| "http://littlesis.org" + e.legacy_url })
          elsif importer.arts_match?
            results[:arts] << ["http://littlesis.org" + importer.match.legacy_url].concat(row)
            arts_count += 1
          elsif importer.arts_matches.count > 1
            results[:arts_multiple] << [importer.raw_name].concat(importer.all_matches.map { |e| "http://littlesis.org" + e.legacy_url })
          elsif importer.postal_match?
            results[:postal] << ["http://littlesis.org" + importer.match.legacy_url].concat(row)
            postal_count += 1
          elsif importer.postal_matches.count > 1
            results[:postal_multiple] << [importer.raw_name].concat(importer.all_matches.map { |e| "http://littlesis.org" + e.legacy_url })
          elsif importer.match?
            results[:match] << ["http://littlesis.org" + importer.match.legacy_url].concat(row)
            match_count += 1
          elsif importer.matches?
            results[:multiple] << [importer.raw_name].concat(importer.all_matches.map { |e| "http://littlesis.org" + e.legacy_url })
          end
        end

        print "#{count} [#{importer.status}] :: #{importer.row}\n"
        total_count = list_count + address_count + arts_count + postal_count + match_count + common_count
        print "#{list_count} list -- #{address_count} address -- #{arts_count} arts -- #{postal_count} postal -- #{match_count} name -- #{common_count} common -- #{total_count} total\n"

      rescue Exception => e
        binding.pry
      end
    end

    begin
      output_csv.close

      open(Rails.root.join("data", "collectors-match-ids.txt"), 'wb') do |file|
        file << match_ids.sort.join("\n")
      end

      open(Rails.root.join("data", "collectors-duplicates.txt"), 'wb') do |file|
        file << duplicates.map { |e| "http://littlesis.org" + e.legacy_url }.join("\n")
      end

      [:previous, :created, :skipped, :multiple, :common_name, :match, :postal_multiple, :arts_multiple, :address_multiple, :postal, :arts, :address, :list].each do |type|
        filename = "collectors-#{type.to_s}.csv"
        print "writing #{filename}...\n"

        CSV.open(Rails.root.join("data", filename), 'wb') do |csv|
          results[type].each do |match|
            csv << match
          end
        end
      end

      print results.map { |k, v| k.to_s + " " + v.count.to_s }
      print "\n"
    rescue Exception => e
      binding.pry
    end    

    binding.pry
  end
end