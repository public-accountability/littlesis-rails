class RelationshipDetails
  attr_accessor :details

  @@bool = lambda { |x| x ? 'yes' : 'no' }
  @@money = lambda { |x| ActiveSupport::NumberHelper::number_to_currency(x, precision: 0) }
  @@percent = lambda { |x| x.to_s + '%' }
  @@human_int = lambda { |x| ActiveSupport::NumberHelper::number_to_human(x) }

  def initialize(relationship)
    @rel = relationship
    @details = []
    calculate_details
  end

  def calculate_details
    case @rel.category_id
    when 1
      position
    when 2
      education
    when 3
      membership
    when 4
      family
    when 5
      donation
    when 6
      transaction
    when 7
      lobbying
    when 8
      social
    when 9
      profession
    when 10
      ownership
    when 11
      hierarchy
    when 12
      generic
    else
    end
  end

  def position
    title
      .add_field(:start_date, 'Start Date')
      .add_field(:end_date, 'End Date')
      .add_field(:is_current, 'Is Current', @@bool)
      .add_field(:is_board, 'Board member', @@bool)
      .add_field(:is_executive, 'Executive', @@bool)
      .add_field(:is_employee, 'Employee', @@bool)
      .add_field(:compensation, 'Compensation', @@money)
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
      .add_field(:membership_dues, 'Dues', @@money)
      .add_field(:notes, 'Notes')
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
      .add_field(:amount, 'Amount', @@money)
      .add_field(:filings, 'FEC Filings')
      .add_field(:goods, 'Goods')
      .add_field(:notes, 'Notes')
  end

  def transaction
    description_field(:description1, @rel.entity)
      .description_field(:description2, @rel.related)
      .add_field(:start_date, 'Start Date')
      .add_field(:end_date, 'End Date')
      .add_field(:is_current, 'Is Current', @@bool)
      .add_field(:amount, 'Amount', @@money)
      .add_field(:goods, 'Goods')
      .add_field(:notes, 'Notes')
  end

  def lobbying
    add_field(:description1, 'Type')
      .add_field(:start_date, 'Start Date')
      .add_field(:end_date, 'End Date')
      .add_field(:is_current, 'Is Current', @@bool)
      .add_field(:amount, 'Amount', @@money)
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

  def profession
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

  def title
    return self unless [1,3,5,10].include? @rel.category_id
    if @rel.description1.nil?
      @details << ['Title', 'Member'] if @rel.category_id == 3
    else
      @details << ['Title', @rel.description1]
    end
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
    e_id = (entity.class == Entity) ? entity.id : entity.to_i
    return nil unless [@rel.entity1_id, @rel.entity2_id].include? e_id
    if e_id == @rel.entity1_id
      [@rel.description2, @rel.related.name]
    else
      [@rel.description1, @rel.entity.name]
    end
  end
end
