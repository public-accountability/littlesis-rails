# frozen_string_literal: true

module SEC
  # owner is a hash that looks like this
  # "reportingOwner": {
  #    "reportingOwnerId": {
  #         "rptOwnerCik": "0001502992",
  #         "rptOwnerName": "Neyland Stephen J"
  #     },
  #     "reportingOwnerAddress": {
  #         "rptOwnerStreet1": "5400 WESTHEIMER CT",
  #         "rptOwnerStreet2": null,
  #         "rptOwnerCity": "HOUSTON",
  #         "rptOwnerState": "TX",
  #         "rptOwnerZipCode": "77056",
  #         "rptOwnerStateDescription": null
  #     },
  #     "reportingOwnerRelationship": {
  #         "isDirector": "1",
  #         "isOfficer": "1",
  #         "isTenPercentOwner": "0",
  #         "isOther": "0",
  #         "officerTitle": "Vice President"
  #       }
  #     }
  # and becomes a struct:
  #   cik                      "0001502992"
  #   name                     "Neyland Stephen J"
  #   location                 "HOUSTON TX 77056"
  #   is_director              "1"
  #   is_officer               "1"
  #   is_ten_percent_owner     "0"
  #   is_other                 "0
  #   officer_title            "Vice President"
  #
  # struct fields: cik, name, location, is_director, is_ten_percent_owner, is_other, officer_title
  #
  ReportingOwner = Struct.new(:cik, :name, :location, :is_director, :is_officer, :is_ten_percent_owner, :is_other, :officer_title, keyword_init: true) do
    def initialize(owner)
      super(
        cik: owner.dig('reportingOwnerId', 'rptOwnerCik'),
        name: owner.dig('reportingOwnerId', 'rptOwnerName'),
        location: location_from_address(owner['reportingOwnerAddress']),
        is_director: owner.dig('reportingOwnerRelationship', 'isDirector'),
        is_officer: owner.dig('reportingOwnerRelationship', 'isOfficer'),
        is_ten_percent_owner: owner.dig('reportingOwnerRelationship', 'isTenPercentOwner'),
        is_other: owner.dig('reportingOwnerRelationship', 'isOther'),
        officer_title:  owner.dig('reportingOwnerRelationship', 'officerTitle')
      )
      freeze
    end

    private

    def location_from_address(owner_address)
      [
        owner_address['rptOwnerCity'],
        owner_address['rptOwnerState'],
        owner_address['rptOwnerZipCode']
      ].join(' ').strip
    end
  end
end
