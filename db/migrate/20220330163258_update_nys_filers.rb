class UpdateNYSFilers < ActiveRecord::Migration[7.0]
  def change
    rename_column :external_data_nys_filers, :filter_type_desc, :filer_type_desc
    rename_column :external_data_nys_filers, :filter_status, :filer_status
  end
end
