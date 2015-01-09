class SecCikScraper
  SOURCES = { 
    yahoo: { 
      url: "http://finance.yahoo.com/q/sec?s=TICKER+SEC+Filings",
      regex: /cik\=(\d+)>/, 
      xpath: "//div[@id='yfi_rt_quote_summary']//div[@class='title']/h2/text()"
    }, 
    edgar: {
      url: "http://www.sec.gov/cgi-bin/browse-edgar?company=&match=&CIK=TICKER&filenum=&State=&Country=&SIC=&owner=exclude&Find=Find+Companies&action=getcompany",
      regex: /CIK\=(\d+)/,
      xpath: "//div[@class='companyInfo']//*[@class='companyName']/text()"
    }
  }

  # define nearly-identical methods for scraping SEC CIK from different sources
  SOURCES.each do |source, options|
    define_singleton_method("get_#{source}_cik_by_ticker".to_sym) do |ticker, match_against_name = nil|
      agent = Mechanize.new
      url = options[:url].gsub("TICKER", CGI.escape(ticker))
      page = agent.get(url) rescue nil
      return nil if page.nil? or page.body.blank?

      match = page.body.match(options[:regex])
      return nil unless match
      
      unless match_against_name.nil?
        names = page.search(options[:xpath])
        return nil if names.blank?

        name = names.first.text.strip

        # print "[#{ticker}] matching #{source} name (#{name}) against provided name (#{match_against_name})\n"

        unless names_match?(name, match_against_name)
          # print "#{source} CIK search: name of company (#{name} [#{ticker}]) doesn't match provided name (#{match_against_name})\n"
          return nil
        end
      end    

      return match[1].to_i
    end
  end

  # one method to syncronously search all sources until a CIK is found
  def self.get_cik_by_ticker(ticker, match_against_name = nil)
    cik = nil

    SOURCES.each do |source, options|
      cik = send("get_#{source}_cik_by_ticker".to_sym, ticker, match_against_name)
      break unless cik.nil?
    end

    cik
  end

  def self.names_match?(name1, name2)
    name1_parts = name1.downcase.gsub(/[.,]/, "").split(/\s/).select { |p| !company_name_words.map(&:downcase).include?(p) }
    name2_parts = name2.downcase.gsub(/[.,]/, "").split(/\s/).select { |p| !company_name_words.map(&:downcase).include?(p) }
    return true if name1_parts.first == name2_parts.first # first words are the same
    return true if (name1_parts.count > 1) and (name1_parts[0..1] - name2_parts == []) # first two words are present
    return false
  end

  def self.company_name_words
    [
      'The',
      'Inc',
      'Incorporated',
      'Co',   
      'Cos',
      'Companies',
      'Company',
      'Corp',
      'Corporation',
      'Bancorp',
      'Bancorporation',
      'Ins',
      'Insurance',
      'Ltd',
      'Limited',
      'LLP',
      'LLC',
      'LP',
      'PA',
      'Chtd',
      'Chartered',
      'Bancorp',
      'Bancorporation',
      'Ins',
      'Stores',
      'Holdings',
      'Group'
    ]
  end
end