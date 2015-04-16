require 'open-uri'

namespace :forbes do
  desc "imports forbes 400 members to a list given file with HTML from forbes.com's full list"
  task import_400_list: :environment do
    list_id = ENV['LIST_ID'].to_i
    infile = ENV['INFILE']
    list = List.find(list_id)
    html  = Nokogiri::HTML(open(infile).read)
    rows = html.css("#list-table-body tr.data")
    rows.each do |row|
      profile_url = "http://forbes.com" + row.css("td.image a").first[:href]
      profile_html = Nokogiri::HTML(open(profile_url).read)
      image = profile_html.css("img.main_info_img").first
      image_url = image ? image[:src] : nil
      name = row.css("td.name a").first.text
      rank = row.css("td.rank").first.text.gsub(/\D/, '').to_i
      net_worth = (row.css("td.archivedworth").first.text.gsub(/[^0-9.]/, '').to_f * 1000000000).to_i
      data = [rank, name, image_url, net_worth]
      # pp data
      importer = ForbesFourHundredImporter.new(list_id)
      importer.import(data)
      entity = importer.entity
      pp entity
      print "\n"
      # binding.pry
    end
  end
end