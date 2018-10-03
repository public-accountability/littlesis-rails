# frozen_string_literal: true

##
# Used to handle server-side rendering
# of a datatable in Javascript.
module Datatable

  class Request
    attr_reader :draw, :start, :length

    def initialize(params)
      %w[draw start length].each do |var|
        instance_variable_set "@#{var}", params.fetch(var).to_i
      end

      freeze
    end
  end

  class Response
  end

  # Superclass for Datatable
  # use .create to create new classes
  # for each model where a datatabl
  class Base
    class_attribute :model

    def self.create(klass)
      Class.new(self) do
        self.model = klass
      end
    end

    def initalize(start:, length:, search: nil)
      @model = self.class.model.to_s.constanize
      @limit = start.to_i
      @offset = length.to_i
      @total_records = @model.count

      if search
      else
        @model.limit(@limit).offset(@offset)
      end
    end
  end

  # NyFiler = Base.create(:NyFiler)
  
  
end
