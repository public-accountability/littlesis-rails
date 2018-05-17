namespace :common_names do
  # This assumes that the file contains only list of names,
  # with one name on each line.
  #
  # The intial list was downloaded from this census data source:
  #   https://www2.census.gov/topics/genealogy/2010surnames/names.zip
  # The top 5000 names were extract via this command:
  # cat Names_2010Census.csv | tail -n +2 | head -n 5000 | awk -F ',' '{ print $1 }' > names.txt
  desc 'import csv of common names'
  task :import, [:file] => :environment do |_, args|
    File.open(args[:file]) do |f|
      f.each_line do |name|
        CommonName.find_or_create_by!(name: name)
      end
    end
  end
end
