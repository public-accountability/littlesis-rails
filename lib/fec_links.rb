class FecLinks
  def self.update
    Reference.where("source like 'http://query.nictusa.com/%'").find_each do |ref|
      ref.source = ref.source.gsub("http://query.nictusa.com/", "http://docquery.fec.gov/")
      ref.save!
    end
  end

  def self.verify
    puts "There are " + Reference.where("source like 'http://query.nictusa.com/%'").count.to_s + " reference links with 'query.nictusa.com'"
  end
end
