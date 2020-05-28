# frozen_string_literal: true

class ExternalData < ApplicationRecord
  DATASETS = { reserved: 0,
               iapd_advisors: 1,
               iapd_schedule_a: 2,
               nycc: 3 }.freeze

  DATASET_NAMES = DATASETS.keys.without(:reserved).map(&:to_s).freeze
  DATASETS_INVERTED = DATASETS.invert.freeze


  enum dataset: DATASETS

  serialize :data, JSON

  has_one :external_entity, required: false, dependent: :destroy

  def merge_data(d)
    if data.nil?
      self.data = d
    elsif data.is_a? Hash
      self.data = data.merge(d)
    else
      raise Exceptions::LittleSisError, 'Incorrectly serialized data attribute'
    end
    self
  end

  def self.dataset_count
    connection.exec_query(<<~SQL).map { |h| h.merge!('dataset' => DATASETS_INVERTED[h['dataset']]) }
      SELECT dataset, COUNT(*) as count
      FROM external_data
      GROUP BY dataset
    SQL
  end

  def self.dataset?(x)
    DATASET_NAMES.include? x.to_s.downcase
  end
end
