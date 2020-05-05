require 'sqlite3'
require Rails.root.join('lib/iapd_importer.rb')

describe "Iapd Dataset" do
  let(:db)  do
    SQLite3::Database.new(":memory:", results_as_hash: true).tap do |db|
      db.execute_batch2 <<SQL
CREATE TABLE advisors (
  name TEXT,
  dba_name TEXT,
  crd_number TEXT,
  sec_file_number TEXT,
  assets_under_management INTEGER,
  total_number_of_accounts INTEGER,
  filing_id INTEGER,
  date_submitted TEXT,
  filename TEXT
);

CREATE TABLE owners (
  filing_id INTEGER,
  scha_3 TEXT,
  schedule TEXT,
  name TEXT,
  owner_type TEXT,
  entity_in_which TEXT,
  title_or_status TEXT,
  acquired TEXT,
  ownership_code TEXT,
  control_person BOOLEAN,
  public_reporting BOOLEAN,
  owner_id TEXT,
  filename TEXT,
  owner_key TEXT,
  advisor_crd_number INTEGER
);

INSERT INTO advisors (name, crd_number, filing_id, filename) VALUES ('Wealth Advisors LLC', '1', 123, 'file1');
INSERT INTO advisors (name, crd_number, filing_id, filename) VALUES ('Billionaire Advisors', '2', 456, 'file1');

INSERT INTO owners (name, owner_type, owner_id, owner_key, filename, advisor_crd_number) VALUES ('Rich Owner', 'I', '3', '3', 'file1', '1');
INSERT INTO owners (name, owner_type, owner_id, owner_key, filename, advisor_crd_number) VALUES ('Rich Owner', 'I', '3', '3', 'file2', '2');

SQL
    end
  end
  before { allow(IapdImporter).to receive(:db).and_return(db) }

  describe 'import' do
    it 'creates 3 ExternalData' do
      expect { IapdImporter.run }.to change(ExternalData, :count).by(3)
    end
  end

  describe 'processor' do
    before { IapdImporter.run }

    it 'creates 3 ExternalEntity' do
      expect { IapdProcessor.run }.to change(ExternalEntity, :count).by(3)
    end

    it 'can automatch Rich Owner' do
      entity = create(:entity_person, name: 'Rich Owner').tap { |e| e.external_links.crd.create!(link_id: '3') }
      IapdProcessor.run
      expect(ExternalEntity.find_by(external_data: ExternalData.iapd_owners.find_by(dataset_id: '3')).entity_id)
        .to eq entity.id
    end
  end
end
