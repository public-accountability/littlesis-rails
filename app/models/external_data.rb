# frozen_string_literal: true

class ExternalData < ApplicationRecord
  DATASETS = { reserved: 0,
               iapd_advisors: 1,
               iapd_schedule_a: 2 }.freeze

  enum dataset: DATASETS

  serialize :data, JSON

  # has_one :external_entity

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

  # def setup_data_column
  #   return self if data.present?

  #   case dataset
  #   when 'iapd_advisors'
  #     self.data = {}
  #   when 'iapd_schedule_a'
  #     self.data = {}
  #   end

  #   self
  # end

  # def wrapped_data
  #   if dataset == 'iapd_owners'
  #     ExternalData::IapdOwner.new(data)
  #   else
  #     data
  #   end
  # end
end
