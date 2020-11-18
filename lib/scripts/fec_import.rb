# frozen_string_literal: true

require 'fec'
require_relative '../importers/fec_importer'

Rails.logger.level = :info

FECImporter.run
