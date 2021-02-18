command = ARGV[0]&.to_sym
dataset = ARGV[1]&.to_sym

if command == :help
  puts(<<HELP)
littlesis data <command> <dataset>

 download | downloads original dataset
 extract  | creates csvs
 load     | loads data into the littlesis database
 export   | creates sql archives
 report   | table statistics
 list     | print list of datasets
HELP
  exit
end

unless %i[download extract load export report list].include? command
  abort "invalid command: #{command}"
end

if command == :list
  ExternalDataset.datasets.each_key { |k| puts k }
  exit
end

unless ExternalDataset.datasets.include? dataset
  abort "invalid dataset: #{dataset}"
end

ExternalDataset.public_send(dataset).public_send(command)
