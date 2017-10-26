class ConvertLegacyReferencesToDocuments < ActiveRecord::Migration

  def self.up
    sql = File.read(Rails.root.join('lib', 'sql', 'convert_reference_to_documents.sql'))
    sql.split(';').map(&:strip).each do |statement|
      ActiveRecord::Base.connection.execute(statement) unless statement.blank?
    end
  end

  def self.down
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE documents")
  end
end
