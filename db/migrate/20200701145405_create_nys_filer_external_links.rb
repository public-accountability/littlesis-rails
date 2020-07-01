class CreateNYSFilerExternalLinks < ActiveRecord::Migration[6.0]
  def up
    NyFilerEntity.includes(:entity).find_each do |filer_entity|
      next if filer_entity.entity.nil?

      filer_entity
        .entity
        .external_links
        .nys_filer
        .find_or_create_by!(link_id: filer_entity.filer_id)
    end
  end
end
