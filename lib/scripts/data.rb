command = ARGV[0]&.to_sym
dataset = ARGV[1]&.to_sym

if command == :help
  puts(<<HELP)
littlesis data <command> <dataset>

 download     | downloads original dataset
 extract      | creates csvs
 load         | loads data into the littlesis database
 export       | creates sql archives
 create_table | creates new table
 report       | table statistics
 list         | print list of datasets
HELP
  exit
end

unless %i[download extract load export create_table report list].include? command
  abort "invalid command: #{command}"
end

if command == :list
  ExternalDataset::DATASETS.each { |k| puts k }
  exit
end

unless ExternalDataset::DATASETS.include? dataset
  abort "invalid dataset: #{dataset}"
end

ExternalDataset.const_get(dataset.to_s.classify).public_send(command)
