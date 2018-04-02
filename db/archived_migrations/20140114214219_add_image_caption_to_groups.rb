class AddImageCaptionToGroups < ActiveRecord::Migration
  def change
    change_table :groups do |t|
      t.string :logo_credit
    end
  end
end
