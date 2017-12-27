class LegacyReference < ApplicationRecord
  self.table_name = 'reference'
  has_one :reference_excerpt

  validates :source, length: { maximum: 1000 }, presence: true
  validates :name, length: { maximum: 100 }
  validates :source_detail, length: { maximum: 255 }
  validates_presence_of :object_id, :object_model

  before_create :legacy_list_object_model_handler

  private

  def legacy_list_object_model_handler
    self.object_model = 'LsList' if object_model == 'List'
  end
end
