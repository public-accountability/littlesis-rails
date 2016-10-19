require 'csv'
module OsCommitteeImporter

    def self.line_to_a(line)
      CSV.parse_line(line, :quote_char => "|")
    end 
    
    def self.process_line(line)
      row = line_to_a(line)
      cmte = OsCommittee.find_or_initialize_by(cycle: row[0], cmte_id: row[1])
      return nil if cmte.persisted?
      cmte.name = row[2]
      cmte.affiliate = row[3]
      cmte.ultorg = row[4]
      cmte.recipid = row[5]
      cmte.recipcode = row[6]
      cmte.feccandid = row[7].presence
      cmte.party = row[8].presence
      cmte.primcode = row[9]
      cmte.source = row[10]
      cmte.sensitive = yes_no_converter row[11]
      cmte.foreign = one_zero_converter row[12]
      cmte.active_in_cycle = one_zero_converter row[13]
      cmte.save!
    end
  
  def self.yes_no_converter(x)
    return nil if x.nil?
    if x.strip.upcase == 'Y'
      return true
    elsif x.strip.upcase == 'N'
      return false
    else
      return nil
    end
  end
  
  def self.one_zero_converter(x)
    return nil if x.nil?
    if x.strip == '1'
      return true
    elsif x.strip == '0'
      return false
    else
      return nil
    end
  end
  
    
  def self.read_file(filepath)
    IO.foreach(filepath) do |line|
      line.force_encoding "utf-8"
      if not line.valid_encoding?
        line.encode!("utf-8", Encoding::ISO_8859_1, :invalid => :replace)
      end
      process_line(line)
    end
  end
  
  def self.start(filepath)
    read_file filepath
  end
  
end
