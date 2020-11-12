# frozen_string_literal: true

module FEC
  module Types
    class Base < ActiveModel::Type::Value
      def self.map=(m)
        @map = m.freeze
        @reverse_map = m.to_a.map(&:reverse).to_h.freeze
      end

      def self.map
        @map
      end

      def self.reverse_map
        @reverse_map
      end

      def deserialize(value)
        return nil if value.blank?

        self.class.map.fetch(value)
      end

      def serialize(value)
        cast(value)
      end

      def cast(value)
        if value.is_a? Symbol
          super(self.class.reverse_map.fetch(value))
        else
          super(value)
        end
      end
    end
  end
end
