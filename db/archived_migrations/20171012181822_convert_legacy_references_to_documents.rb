class ConvertLegacyReferencesToDocuments < ActiveRecord::Migration

  def self.up
    sql = File.read(Rails.root.join('lib', 'sql', 'convert_reference_to_documents.sql'))
    sql.split(';').map(&:strip).each do |statement|
      ApplicationRecord.connection.execute(statement) unless statement.blank?
    end
  end

  def self.down
    ApplicationRecord.connection.execute("TRUNCATE TABLE documents")
  end
end
