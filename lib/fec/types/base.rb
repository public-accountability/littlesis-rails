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
        return if value.empty?

        self.class.map.fetch(value)
      end

      def cast(value)
        self.class.reverse_map.fetch(value)
      end
    end
  end
end
