module OsCandidateImporter

  def self.process_line(line)
    row = CSV.parse_line(line,  :quote_char => "|").map{ |x| nil_or_strip(x) }
    cand = OsCandidate.find_or_initialize_by(cycle: row[0], crp_id: row[2])
    return nil if cand.persisted?
    cand.feccandid = row[1]
    cand.name = row[3]
    cand.party = row[4]
    cand.distid_runfor = row[5]
    cand.distid_current = row[6]
    cand.currcand = yes_no_converter row[7]
    cand.cyclecand = yes_no_converter row[8]
    cand.crpico = row[9]
    cand.recipcode = row[10]
    cand.nopacs = row[11]
    cand.save!
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
  
  def self.nil_or_strip(x)
    if x.blank?
      return nil
    else
      return x.strip
    end
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

  def self.start(filepath)
    read_file filepath
  end
  
end
