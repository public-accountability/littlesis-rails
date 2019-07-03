# frozen_string_literal: true

module OsImporter
  def self.import_indivs(filepath)
    outfile = File.new("#{filepath}_errors.txt", 'w')
    processed = 0
    errors = 0
    IO.foreach(filepath) do |line|
      clean_line = OsImporter.remove_spaces_between_quoted_field_and_comma(line)
      CSV.parse(clean_line, :quote_char => '|') do |row|
        OsImporter.insert_row row
      end
      processed += 1
      printf("processed %s lines\n", processed) if (processed % 5000).zero?
    rescue => e
      printf("ERROR -- %s \n     with line: %s\n", e, line)
      errors += 1
      outfile.write(line)
    end
    outfile.close
    printf("** processed %s donations\n** skipped %s lines with errors\n", processed, errors)
  end

  def self.date_parse(d)
    return nil if d.nil?

    month, day, year = d.strip.split('/')
    [year, month, day].join('-')
  end

  def self.fec_cycle_id(row)
    "#{row[0].strip}_#{row[1].strip}"
  end

  def self.insert_row(row)
    donation = OsDonation.find_or_initialize_by(fec_cycle_id: OsImporter.fec_cycle_id(row))

    donation.cycle = row[0]
    donation.fectransid = row[1].strip
    donation.contribid = row[2].strip
    donation.contrib = row[3].strip.presence
    donation.recipid = row[4].strip.presence
    donation.orgname = row[5].strip.presence
    donation.ultorg = row[6].strip.presence
    donation.realcode = row[7].strip.presence
    donation.date = date_parse(row[8].presence)
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

    if donation.changed?
      printf("OsDonation %s updated\n", donation.id) if donation.persisted?
      donation.save!
    end
  end

  def self.remove_spaces_between_quoted_field_and_comma(line)
    line.gsub(/\|\s+,/, '|,')
  end
end
