require 'csv'
require 'json'

puts JSON.pretty_generate(
       CSV.read(ARGV.first, headers: true).map do |row|
         {
           'name' => row['Name'],
           'url' => row['LittleSis link'],
           'position' => row['Position'],
           'date' => row['Date of departure announcement'],
           'where_to' => row['Where to?'],
           'org_url' => row['Org Link']
         }
       end
     )
