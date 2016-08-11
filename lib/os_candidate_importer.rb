module OsCandidateImporter
  FILEPATH = Rails.root.join('data', 'candidates.csv')

  def self.process_line(line)
    row = CSV.parse_line(line,  :quote_char => '"').map{ |x| x.strip  }
    
    OsCandidate.find_or_create_by!(
       crp_id: row[0],
       name: row[1],
       district: row[2],
       party: row[3],
       fecanid: row[4],
       year: row[5]
    )
    
  end

  def self.start
    IO.foreach(FILEPATH) do |line|
      process_line(line)
    end
  end
  
end
