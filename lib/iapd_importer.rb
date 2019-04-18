# frozen_string_literal: true

# Import SEC's Iapd into external_datasets
# The data files are created here: https://github.com/public-accountability/iapd
#
# Old version: https://gist.github.com/aepyornis/0858e2fc4d516bc0f6f22f2717f6f668
#
module IapdImporter
  ADVISORS_FILE = Rails.root.join('data', 'iapd', 'advisors.json').to_s
  OWNERS_FILE = Rails.root.join('data', 'iapd', 'owners.json').to_s

  DATE_FROM_FILENAME = proc { |x| x['filename'].slice(-12, 8) }

  def self.sec_url(crd_number)
    "https://adviserinfo.sec.gov/Firm/#{crd_number}"
  end

  def self.load_json_file(file)
    JSON.parse File.open(file).read
  end

  def self.advisors
    @advisors ||= load_json_file(ADVISORS_FILE)
                    .map { |crd_number, advisor_data| advisor_to_struct(crd_number, advisor_data) }
  end

  def self.owners
    @owners ||= load_json_file(OWNERS_FILE)
                    .map { |owner_key, owner_data| owner_to_struct(owner_key, owner_data) }
  end

  def self.advisor_to_struct(crd_number, advisor_data)
    crd_number = crd_number.to_i
    name = advisor_data.max_by(&DATE_FROM_FILENAME).fetch('name')
    ExternalDataset::IapdAdvisor.new(crd_number, name, advisor_data)
  end

  def self.owner_to_struct(owner_key, owner_data)
    name = owner_data.max_by(&DATE_FROM_FILENAME).fetch('name')
    ExternalDataset::IapdOwner.new(owner_key, name, owner_data)
  end

  def self.struct_to_hash(s)
    s.to_h.tap do |h|
      h.store :class, s.class.name
    end
  end

  def self.import_advisors
    advisors.each do |advisor|
      next if row_exists?(advisor.crd_number.to_s)

      ExternalDataset.create!(name: 'iapd',
                              dataset_key: advisor.crd_number.to_s,
                              row_data: struct_to_hash(advisor),
                              primary_ext: :org)

      ColorPrinter.with_logger.print_gray "[IapdImporter] Created: #{advisor.crd_number}"
    end
  end

  def self.import_owners
    owners.each do |owner|
      next if row_exists?(owner.owner_key)

      ExternalDataset.create!(name: 'iapd',
                              dataset_key: owner.owner_key,
                              row_data: struct_to_hash(owner))

      ColorPrinter.print_gray "[IapdImporter] created: #{owner.owner_key}"
    end
  end

  def self.row_exists?(key)
    if ExternalDataset.exists?(name: 'iapd', dataset_key: key)
      ColorPrinter.with_logger.print_blue "[IapdImporter] #{key} exists"
      return true
    end
    false
  end
end
