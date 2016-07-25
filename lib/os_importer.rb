module OsImporter

  def OsImporter.import_indivs(filepath)
    IO.foreach(filepath) do |line|
      begin 
        CSV.parse(line, :quote_char => "|") do |row| 
          donation = OsDonation.find_or_initialize_by(fec_cycle_id: OsImporter.fec_cycle_id(row))

          donation.cycle = row[0]
          donation.fectransid = row[1].strip
          donation.contribid = row[2].strip
          donation.contrib = row[3].strip.presence
          donation.recipid = row[4].strip.presence
          donation.orgname = row[5].strip.presence
          donation.ultorg = row[6].strip.presence
          donation.realcode = row[7].strip.presence
          donation.date = date_parse(row[8].strip.presence)
          donation.amount = row[9]
          donation.street = row[10].strip.presence
          donation.city = row[11].strip.presence
          donation.state = row[12].strip.presence
          donation.zip = row[13].strip.presence
          donation.recipcode = row[14].strip.presence
          donation.transactiontype = row[15].strip.presence
          donation.cmteid = row[16].strip.presence
          donation.otherid = row[17].strip.presence
          donation.gender = row[18].strip.presence
          donation.microfilm = row[19].strip.presence
          donation.occupation = row[20].strip.presence
          donation.employer = row[21].strip.presence
          donation.source = row[22].strip.presence

          donation.create_fec_cycle_id
          
          name = NameParser.os_parse(donation.contrib)
          donation.name_last = name[:last]
          donation.name_first = name[:first]
          donation.name_middle = name[:middle]
          donation.name_prefix = name[:prefix]
          donation.name_suffix = name[:suffix]

          donation.save!
        end  
      rescue CSV::MalformedCSVError => e
        printf("CSV Error: %s \n    with line: %s\n", e, line)
      rescue 
        printf("ERROR with this line:\n     %s\n", line)
        raise
      end
    end
  end
  
  def OsImporter.date_parse(d)
    return nil if d.nil?
    month, day, year = d.split('/')
    [year, month, day].join('-')
  end
  
  def OsImporter.fec_cycle_id(row)
    row[0].strip + "_" + row[1].strip
  end
end
