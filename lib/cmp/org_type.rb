module Cmp
  class OrgType
    attr_reader :name, :extension, :type_id
    TYPES = {
      1 => {
        name: 'Policy-Planning',
        extension: 'ThinkTank'
      },
      2 => {
        name: 'Industry Association',
        extension: 'IndustryTrade'
      },
      3 => {
        name: 'Advocacy and Consensus',
        extension: 'EliteConsensus'
      },
      4 => {
        name: 'University',
        extension: 'School'
      },
      5 => {
        name: 'Research Institute',
        extension: 'ResearchInstitute'
      },
      6 => {
        name: 'Foundation',
        extension: 'Philanthropy'
      },
      7 => {
        name: 'Climate Advisory',
        extension: 'GovernmentAdvisoryBody'
      },
      8 => {
        name: 'Quasi-state',
        extension: nil
      },
      9 => {
        name: 'Corporation',
        extension: 'Business'
      }
    }.freeze

    def initialize(type_id)
      @type_id = type_id.to_i
      raise ArgumentError, "type_id is a number between 1 and 9" unless (1..9).cover? @type_id
      @extension = TYPES.dig @type_id, :extension
      @name = TYPES.dig @type_id, :name
    end
  end
end
