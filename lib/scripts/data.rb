command = ARGV[0]&.to_sym
dataset = ARGV[1]&.to_sym

HELP = <<HELP
littlesis data <command> <dataset>

 download     | downloads original dataset
 extract      | creates csvs
 load         | loads data into the littlesis database
 export       | creates sql archives
 create_table | creates new table
 report       | table statistics
 list         | print list of datasets
HELP

if command == :help
  puts HELP
  exit
end

unless %i[download extract load export create_table report list].include? command
  abort "invalid command: #{command}\n#{HELP}"
end

if command == :list
  ExternalDataset::DATASETS.each { |d| puts d }
  exit
end

if command == :report && dataset.nil?
  ExternalDataset::DATASETS.each do |d|
    ExternalDataset.fetch_dataset_class(d).report
  end
  exit
end

unless ExternalDataset::DATASETS.include? dataset
  abort "invalid dataset: #{dataset}"
end

ExternalDataset.fetch_dataset_class(dataset).public_send(command)
