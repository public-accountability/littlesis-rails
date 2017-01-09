class LengthenReferenceSourceAndSourceDetailColumns < ActiveRecord::Migration
  def change
    change_column :reference, :source, :string, limit: 1000
    change_column :reference, :source_detail, :string, limit: 255
  end
end
