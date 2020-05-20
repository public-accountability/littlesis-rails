# frozen_string_literal: true

require Rails.root.join('lib/iapd_importer.rb').to_s
require Rails.root.join('lib/iapd_processor.rb').to_s

ColorPrinter.print_blue "Importing IAPD data"
IapdImporter.run
ColorPrinter.print_blue "Processing IAPD data"
IapdProcessor.run
