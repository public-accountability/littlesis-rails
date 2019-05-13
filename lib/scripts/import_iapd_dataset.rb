# Imports Iapd Dataset
#
#  bin/rails runner ./lib/scripts/import_iapd_dataset.rb
#

require 'iapd_importer'

IapdImporter.import_advisors
IapdImporter.import_owners
