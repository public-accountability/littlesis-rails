require 'sequel'
require 'street_address'

class OpensecretsAddressImporter

  attr_reader :address_hashes

  def initialize(entity)
    @entity = entity
    config = Rails.configuration.database_configuration[Rails.env]
    @db = Sequel.connect("mysql2://littlesis:#{config['password']}@localhost/littlesis_raw")
    @addresses = []
    @incoming = []
    import
    @db.disconnect
  end

  def addresses
    @addresses
  end

  def incoming
    @incoming
  end

  def save
    @entity.addresses.concat(@addresses)
    @entity.save
  end

  def import
    if @entity.os_entity_transactions.verified.count == 0
      # print "entity doesn't have any matched opensecrets donations\n"
      return
    end

    donations = @db[:os_donation]
    trans = @entity.os_entity_transactions.verified.map { |t| [t.cycle, t.transaction_id] }

    trans.each do |cycle_id, trans_id|
      row = donations.where(cycle: cycle_id, row_id: trans_id).first
      next if row.nil? or row[:street].to_s.empty?
      oneliner = "#{row[:street]}, #{row[:city]}, #{row[:state]} #{row[:zip]}"
      @incoming << address = Address.parse(oneliner, row_to_attributes(row))
      next unless address.valid?
      import_or_replace(address)
    end  
  end

  def row_to_attributes(row)
    state = row[:state] ? AddressState.find_by(abbreviation: row[:state].upcase) : nil

    {
      street1: row[:street],
      city: row[:city],
      postal: row[:zip],
      state: state
    }
  end

  def entity_address?(address)
    @entity.addresses.find { |a| a.same_as?(address) }
  end

  def imported_address?(address)
    @addresses.find { |a| a.same_as?(address) }
  end

  def import_or_replace(address)
    if a = entity_address?(address)
      a.street2_from(address)
    elsif a = imported_address?(address)
      a.street2_from(address)
    else
      @addresses << address
    end
  end

  def updated_addresses
    @entity.addresses.select(&:changed?)
  end
end