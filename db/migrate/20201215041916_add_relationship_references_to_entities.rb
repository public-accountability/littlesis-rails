class AddRelationshipReferencesToEntities < ActiveRecord::Migration[6.0]
  def change
    Relationship.includes(:entity, :related).find_each do |relationship|
      relationship.documents.each do |document|
        if relationship.entity.nil?
          Rails.logger.warn "relationship #{relationship.id} is missing entity1"
        else
          relationship.entity.references.find_or_create_by(document_id: document.id)
        end

        if relationship.related.nil?
          Rails.logger.warn "relationship #{relationship.id} is missing entity2"
        else
          relationship.related.references.find_or_create_by(document_id: document.id)
        end
      end
    end
  end
end
