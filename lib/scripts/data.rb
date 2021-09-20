command = ARGV[0]&.to_sym
dataset = ARGV[1]&.to_sym

HELP = <<HELP
littlesis data <command> <dataset>

 download      | downloads original dataset
 transform     | transforms data into csvs
 create_table  | creates new table
 load          | loads data into the littlesis database
 report        | table statistics
 export        | creates sql archives
 list          | print list of datasets
 delete        | removes all removes from the table
 etl           | runs download, transform, load, report
HELP

case command
when :help
  puts HELP
  exit
when :list
  ExternalDataset.datasets.each { |d| puts d }
  exit
end

unless %i[download transform load export create_table report list etl delete].include? command
  abort "invalid command: #{command}\n#{HELP}"
end

unless ExternalDataset.datasets.include?(dataset) || (command == :report && dataset.nil?)
  abort "invalid dataset: #{dataset}"
end

case command
when :report
  if dataset.nil?
    ExternalDataset.datasets.each do |d|
      ExternalDataset.public_send(d).report
    end
  else
    ExternalDataset.public_send(dataset).report
  end
when :etl
  puts "Working on #{dataset}: "
  %i[download transform load report].each do |c|
    ExternalDataset.public_send(dataset).public_send(c)
    puts "\t✓ #{c}" unless c == :report
  end
when :delete
  printf "If you are you sure, type yes: "
  if STDIN.gets.chomp == 'yes'
    table_name = ExternalDataset.public_send(dataset).table_name
    ApplicationRecord.execute_sql "TRUNCATE #{table_name} RESTART IDENTITY"
  end
else
  ExternalDataset.public_send(dataset).public_send(command)
end
