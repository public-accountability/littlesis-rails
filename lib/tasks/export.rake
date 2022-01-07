require 'sapi_exporter'

namespace :export do
  task sapi: :environment do
    SapiExporter.run
  end
end
