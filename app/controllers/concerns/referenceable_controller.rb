module ReferenceableController
  private

  def need_to_create_new_reference
    existing_reference_params['reference_id'].blank? && existing_reference_params['just_cleaning_up'].blank?
  end

  def reference_params(param_key = :reference)
    params.require(param_key).permit(:name, :url, :excerpt, :publication_date, :ref_type)
  end

  def existing_reference_params
    params.require(:reference).permit(:just_cleaning_up, :reference_id)
  end
end
