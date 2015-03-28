require 'csv'

namespace :collectors do
  desc "import art collectors from CSV file"
  task :import_list, [:list_id, :filename, :create_csv, :detailed_logs, :couples_only] => [:environment] do |task, args|
    list = List.find(args[:list_id])
    create_csv = args.to_hash.fetch(:create_csv, "true") == "true"
    detailed_logs = args.to_hash.fetch(:detailed_logs, "false") == "true"
    couples_only = args.to_hash.fetch(:couples_only, "false") == "true"
    offset = (ENV['OFFSET'] or 0).to_i

    output_ary = [] # just in case file write fails?
    output_ary << "ID,First Name,Last Name,Address,City,State,Zip,Country,Pictures,News,Profession".split(",")

    if create_csv
      output_csv = CSV.open("data/collectors-with-ids.csv", "wb")
      output_csv << "ID,First Name,Last Name,Address,City,State,Zip,Country,Pictures,News,Profession".split(",")
    end

    if detailed_logs
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

    end

    count = 0
    total_count = previous_count = list_count = address_count = arts_count = postal_count = match_count = common_count = 0
    partner1_ids = ListEntity.joins(entity: :couple).where(entity: { primary_ext: 'Couple' }).pluck('couple.partner1_id')
    partner2_ids = ListEntity.joins(entity: :couple).where(entity: { primary_ext: 'Couple' }).pluck('couple.partner2_id')
    already_imported_ids = ListEntity.where(list_id: list.id).pluck(:entity_id).concat(partner1_ids).concat(partner2_ids)
    collector_list_ids = ListEntity.where(list_id: 330).pluck(:entity_id)
    cultural_org_ids = Entity.with_exts(['Cultural']).pluck(:id)
    arts_related_ids = Link.where(entity1_id: cultural_org_ids, category_id: [1, 3, 5]).pluck(:entity2_id).uniq

    CSV.foreach(args[:filename], encoding: 'windows-1251:utf-8') do |input_row|
      begin
        # default offset is to skip label row
        if count <= offset
          count += 1
          next
        end

        count += 1

        # skip if already has id
        # next if input_row.first.present?
        entity_id = input_row.first

        input_row = input_row.drop(1)

        input_row.map! { |cell| cell.present? ? cell.gsub(/[\n\r]/, " ").gsub(/\s{2,}/, " ") : nil }

        full_name = (input_row[0].to_s + " " + input_row[1].to_s).strip
        is_couple = NameParser.couple_name?(full_name)

        if is_couple
          first = input_row[0].to_s
          last = input_row[1].to_s

          if input_row[0].match(/&|\band\b/)
            if input_row[0].strip.match(/(&|\band)$/)
              names = [first.strip.gsub(/(&|\band)$/, '').strip, last.strip]
              rows = names.map do |name|
                parts = name.split(/\s/)
                if parts.count > 2 and ["de", "von", "la"].include?(parts[-2].downcase)
                  last_num = 2
                else
                  last_num = 1
                end
                [parts.take(last_num).join(" ")].concat([parts.drop(last_num).join(" ")]).concat(input_row.drop(2))                
              end
            else
              rows = first.split(/&|\band\b/).map { |first| [first.strip, last.strip].concat(input_row.drop(2)) }
            end
          else
            rows = [[first.strip, last.split(/&|\band\b/).first.strip]]
            name = last.split(/&|\band\b/).last.strip
            parts = name.split(/\s/)

            if parts.count > 2 and ["de", "von", "la"].include?(parts[-2].downcase)
              last_num = 2
            else
              last_num = 1
            end

            rows << [parts.take(last_num).join(" ")].concat([parts.drop(last_num).join(" ")]).concat(input_row.drop(2))
          end

          # split image cell into two or discard
          couple_image = nil
          images = input_row[7].to_s.split(/\s+/)
          if images.count == rows.count
            # if two image urls, assign each to corresponding row
            rows.each_with_index do |row, i|
              rows[i][7] = images[i]
            end
          else
            # if not two image urls, set row images to nil
            rows.each_with_index do |row, i|
              rows[i][7] = nil
            end

            if images.count == 1
              couple_image = images.first
            end
          end

          # split entity_id if present
          if entity_id.present?
            c = Entity.find(entity_id).couple
            entity_ids = [c.partner1_id, c.partner2_id]
          else
            entity_ids = [nil, nil]
          end

          couple = []
        else
          next if couples_only
          rows = [input_row]
        end

        rows.each_with_index do |row, i|
          importer = EntityNameAddressCsvImporter.new(row)

          if is_couple
            id = entity_ids[i]
          else
            id = entity_id
          end

          # entity already imported, so we import image and address if they don't already exist
          if id.present?
            entity = Entity.where(id: id).first
            next unless entity
            importer.entity = entity
            couple << entity if is_couple
            importer.parse_address
            print "#{count} + imported address for #{entity.name}\n" if importer.create_address
            print "#{count} + imported image for #{entity.name}\n" if importer.create_image
            next
          end

          importer.is_couple = is_couple
          importer.already_imported_ids(already_imported_ids)
          importer.collector_list_ids(collector_list_ids)
          importer.arts_related_ids(arts_related_ids)

          if entity = importer.import
            match_ids << entity.id if detailed_logs and entity.id? and !importer.previous_import?
            entity.lists << list unless is_couple or entity.list_ids.include?(list.id)
            entity.save!
            couple << entity if is_couple

            duplicates << entity if detailed_logs and importer.matches?
            output_csv << [entity.id].concat(row) if create_csv and !is_couple
            output_ary << [entity.id].concat(row) if !is_couple
          else
            output_csv << [""].concat(row) if create_csv and !is_couple
            output_ary << [""].concat(row) if !is_couple
          end

          if detailed_logs
            match_type = importer.match_type
            match_types[match_type] += 1 if match_type
            address_type = importer.address_type
            address_types[address_type] += 1 if address_type
            common_name_type = importer.common_name_type
            common_name_types[common_name_type] += 1 if common_name_type

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
          end

          print "#{count} [#{importer.status}] :: #{importer.row}\n"
          total_count = list_count + address_count + arts_count + postal_count + match_count + common_count
          print "#{list_count} list -- #{address_count} address -- #{arts_count} arts -- #{postal_count} postal -- #{match_count} name -- #{common_count} common -- #{total_count} total\n"
        end

        if is_couple
          unless entity = Entity.find_couple(couple[0].id, couple[1].id)
            entity = Entity.create_couple(full_name, couple[0], couple[1])
          end

          if couple_image.present?
            if image = entity.add_image_from_url(couple_image) and couple_image.present? and input_row[10].present?
              image.caption = input_row[10]
              image.save
            end
          end

          entity.lists << list unless entity.list_ids.include?(list.id)
          entity.save!

          unless rel = Link.where(entity1_id: couple[0].id, entity2_id: couple[1].id, category_id: 4).first
            rel = Relationship.create(
              entity1_id: couple[0].id, 
              entity2_id: couple[1].id,
              category_id: 4, # Family
              description1: 'partner',
              description2: 'partner',
              is_current: true,
              last_user_id: Lilsis::Application.config.system_user_id
            )
          end

          output_csv << [entity.id].concat(input_row) if create_csv
          output_ary << [entity.id].concat(input_row)    
        end
      rescue Exception => e
        binding.pry
      end
    end

    begin
      output_csv.close if create_csv

      if detailed_logs
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
      end

    rescue Exception => e
      binding.pry
    end    

    binding.pry
  end

  desc "import NOZA contributions from CSV file"
  task :import_noza, [:list_id, :filename] => [:environment] do |task, args|
    raise "must provide list id" unless args[:list_id].present?
    count = 0

    results = []

    CSV.foreach(args[:filename], encoding: 'windows-1251:utf-8') do |row|
      count += 1

      # skip header row
      next if count == 1

      # skip if missing donor name
      if row[3].blank? 
        binding.pry
        next
      end

      importer = NozaDonationImporter.new(row)
      importer.collector_list_id = args[:list_id]
      importer.import
      ary = [
        count - 1,
        importer.donation ? importer.donation.id : nil,
        importer.raw_name, 
        importer.donor_first + " " + importer.donor_last, 
        importer.donor ? importer.donor.name : nil,
        importer.recipient_name,
        importer.recipient ? importer.recipient.name : nil,
        importer.recipient_match_type,
        importer.donation ? importer.donation.amount : nil,
        importer.donation ? importer.donation.amount2 : nil
      ]
      results << ary
      print "#{count} #{ary}\n"
    end

    CSV.open(Rails.root.join("data", "collectors-noza-results.csv"), 'wb') do |csv|
      results.each do |ary|
        csv << ary
      end
    end

    binding.pry
  end
end