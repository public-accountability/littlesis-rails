namespace :references do
  desc "replace form3 references with human-redable versions"
  task fix_sec_urls: :environment do
    sources = []
    refs = Reference.where("source LIKE ?", 'http://www.sec.gov/Archives/edgar/data%.xml')
    print "fixing xml url in #{refs.count} sec references...\n"
    refs.each_with_index do |ref, i|
      unless ref.source.match(/xslF345X03/)
        ref.source = ref.source.gsub(/[^\/]+\.xml/i, 'xslF345X03/\0')
        ref.save
        print "[#{i}] + fixed #{ref.source}\n"
      end
    end
  end
end