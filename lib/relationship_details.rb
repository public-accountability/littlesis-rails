class RelationshipDetails
  attr_accessor :details

  @@bool = lambda { |x| x ? 'yes' : 'no' }

  def initialize(relationship)
    @rel = relationship
    @details = Array.new
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
      transaciton
    when 7
      lobbying
    when 8
      social
    when 9
      profession
    when 10
      ownership
    when 11
      hiearchy
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
      .add_field(:compensation, 'Compensation')
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
      .add_field(:membership_dues, 'Dues')
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
  end

  def transaciton
  end

  def lobbying
  end

  def social
  end

  def profession
  end

  def ownership
  end

  def hiearchy
  end

  def generic
  end


  def title
    return self unless [1,3,5,10].include? @rel.category_id 
    if @rel.description1.nil?
      if @rel.category_id == 3
        @details << ['Title', 'member']
      end
    else
      @details << ['Title', @rel.description1 ]
    end
    self
  end

  # input: symbol, string, lambda
  def add_field(field, header, converter = lambda { |x| x.to_s })
    unless @rel.send(field).nil?
      @details << [ header, converter.call(@rel.send(field)) ]
    end
    self
  end

  
  # For some categories, "description1" and "description2" are the
  # the headers and the entity name are the fields
  # input: symbol, <Entity>
  def description_field(description, entity)
    unless @rel.send(description).nil? or entity.name.blank?
      @details << [ @rel.send(description).capitalize, entity.name ]
    end
    self
  end

end
