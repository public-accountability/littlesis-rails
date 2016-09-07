class RelationshipDetails
  attr_accessor :details

  @@bool = lambda { |x| x ? 'yes' : 'no' }

  def initialize(relationship)
    @rel = relationship
    @details = Array.new
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
      .add_fields(:notes, 'Notes')
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

end
