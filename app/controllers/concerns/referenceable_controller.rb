# frozen_string_literal: true

module ReferenceableController
  private

  def need_to_create_new_reference
    (existing_reference_params['reference_id'] || existing_reference_params['document_id']).blank? &&
      existing_reference_params['just_cleaning_up'].blank?
  end

  def existing_document_id
    if existing_reference_params['document_id'].present?
      existing_reference_params['document_id']
    end
  end

  def reference_params(param_key = :reference)
    params
      .require(param_key)
      .permit(:name, :url, :excerpt, :publication_date, :ref_type)
      .to_h
  end

  def existing_reference_params
    params.require(:reference).permit(:just_cleaning_up, :reference_id, :document_id)
  end
end
