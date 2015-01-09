namespace :companies do
  desc "get missing company SEC CIKs using tickers"
  task get_sec_ciks: :environment do
    # get non-deleted public companies that have tickers and don't have SEC CIKs
    pcs = PublicCompany.joins(:entity).where("ticker is not null and sec_cik is null")

    print "searching for SEC CIKs for #{pcs.count} companies with tickers...\n"

    pcs.each do |pc|
      print "#{pc.entity.name} (#{pc.ticker})...\n"

      # match ticker search result against entity name
      cik = SecCikScraper.get_cik_by_ticker(pc.ticker, pc.entity.name)
      
      unless cik.nil?
        pc.sec_cik = cik
        pc.save
        print "+ found SEC CIK: #{pc.sec_cik}\n"
      end
    end
  end
end