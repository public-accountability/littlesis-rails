# frozen_string_literal: true

class RelationshipDetails
  include ActiveSupport::NumberHelper

  attr_accessor :details

  @@bool = lambda { |x| x ? 'yes' : 'no' }
  @@percent = lambda { |x| x.to_s + '%' }
  @@human_int = lambda { |x| ActiveSupport::NumberHelper.number_to_human(x) }

  def initialize(relationship)
    @rel = relationship
    @details = []
    calculate_details
    freeze
  end

  # Calls the appropriate method in CategoryDetails below for the category
  def calculate_details
    public_send @rel.category.name.downcase
  end

  concerning :CategoryDetails do
    def position
      title
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:is_board, 'Board member', @@bool)
        .add_field(:is_executive, 'Executive', @@bool)
        .add_field(:is_employee, 'Employee', @@bool)
        .add_field(:compensation, 'Compensation', format_in_usd)
        .add_field(:notes, 'Notes')
    end

    def education
      add_field(:description1, 'Type')
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:degree, 'Degree')
        .add_field(:education_field, 'Field')
        .add_field(:is_dropout, 'Is Dropout', @@bool)
        .add_field(:notes, 'Notes')
    end

    def membership
      title
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:membership_dues, 'Dues', format_in_usd)
        .add_field(:notes, 'Notes')

      elected_term if @rel.us_legislator?
    end

    def family
      description_field(:description1, @rel.entity)
      description_field(:description2, @rel.related)
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:notes, 'Notes')
    end

    def donation
      add_field(:description1, 'Type')
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:amount, 'Amount', format_with_currency)
        .add_field(:filings, filings_text)
        .add_field(:goods, 'Goods')
        .add_field(:notes, 'Notes')
    end

    def transaction
      description_field(:description1, @rel.entity)
        .description_field(:description2, @rel.related)
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:amount, 'Amount', format_with_currency)
        .add_field(:goods, 'Goods')
        .add_field(:notes, 'Notes')
    end

    def lobbying
      add_field(:description1, 'Type')
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:amount, 'Amount', format_with_currency)
        .add_field(:filings, 'LDA Filings')
        .add_field(:notes, 'Notes')
    end

    def social
      description_field(:description1, @rel.entity)
        .description_field(:description2, @rel.related)
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:notes, 'Notes')
    end

    def professional
      description_field(:description1, @rel.entity)
        .description_field(:description2, @rel.related)
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:notes, 'Notes')
    end

    def ownership
      title
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:percent_stake, 'Percent Stake', @@percent)
        .add_field(:shares_owned, 'Shares', @@human_int)
        .add_field(:notes, 'Notes')
    end

    def hierarchy
      description_field(:description1, @rel.entity)
        .description_field(:description2, @rel.related)
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:notes, 'Notes')
    end

    def generic
      description_field(:description1, @rel.entity)
        .description_field(:description2, @rel.related)
        .add_field(:start_date, 'Start Date')
        .add_field(:end_date, 'End Date')
        .add_field(:is_current, 'Is Current', @@bool)
        .add_field(:notes, 'Notes')
    end
  end

  def title
    return self unless [1, 3, 5, 10].include? @rel.category_id

    if @rel.description1.nil?
      @details << ['Title', 'Member'] if @rel.category_id == 3
    else
      @details << ['Title', @rel.description1]
    end
    self
  end

  # Adds these field if they are present: state, district, party
  def elected_term
    et = @rel.membership.elected_term
    @details << ['State', et['state']]

    if et['district']
      if et['district'].zero?
        @details << %w[District At-large]
      elsif et['district'] == -1
        @details << %w[District Unknown]
      else
        @details << ['District', et['district'].to_s]
      end
    end

    @details << ['Party', et['party']] if et['party']
    self
  end

  # input: symbol, string, lambda
  def add_field(field, header, converter = ->(x) { x.to_s })
    unless @rel.send(field).nil?
      @details << [header, converter.call(@rel.send(field))]
    end
    self
  end

  # For some categories, "description1" and "description2" are the
  # the headers and the entity name are the fields
  # input: symbol, <Entity>
  def description_field(description, entity)
    unless @rel.send(description).nil? || entity.name.blank?
      @details << [@rel.send(description).capitalize, entity.name]
    end
    self
  end

  # Family relationships work like this:
  # - Entity1 is the description1 of entity2
  # - entity2 is the description2 of entity1
  # This functions allows you to pass in the entity for whom you want the details for
  # and it will it provide you the OTHER person in the family relationship.
  # input: <Entity> or FixNum|String (entity id)
  # output: [ 'title', 'name' ]
  def family_details_for(entity)
    e_id = Entity.entity_id_for(entity)
    return nil unless [@rel.entity1_id, @rel.entity2_id].include? e_id

    if e_id == @rel.entity1_id
      [@rel.description2, @rel.related.name]
    else
      [@rel.description1, @rel.entity.name]
    end
  end

  private

  # distinguishes between NYC and federal campaign contributions
  def filings_text
    if @rel.description1 == 'NYS Campaign Contribution'
      'Filings'
    else
      'FEC Filings'
    end
  end

  def format_with_currency
    proc do |_x|
      number_to_currency(
        @rel.amount,
        unit: @rel.currency.upcase,
        precision: 0,
        format: '%n %u'
      )
    end
  end

  def format_in_usd
    ->(x) { number_to_currency(x, unit: 'USD', precision: 0, format: '%n %u') }
  end
end
