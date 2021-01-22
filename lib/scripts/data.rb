command = ARGV[0]&.to_sym
dataset = ARGV[1]&.to_sym

help = <<HELP
littlesis data <command> <dataset>

 download | downloads original dataset
 extract  | creates csvs
 load     | loads data into the littlesis database
 export   | creates sql archives
 report   | table statistics
HELP

unless %i[download extract load export report].include? command
  abort "invalid command: #{command}"
end

unless ExternalDataset.datasets.include?(dataset)
  abort "invalid dataset: #{dataset}"
end

ExternalDataset.public_send(dataset).public_send(command)
