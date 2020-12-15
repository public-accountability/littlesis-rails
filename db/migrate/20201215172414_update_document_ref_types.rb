class UpdateDocumentRefTypes < ActiveRecord::Migration[6.0]
  def change
    Document.where("ref_type = 3 OR ref_type = 4").update_all(ref_type: 1)
  end
end
