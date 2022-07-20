# frozen_string_literal: true

class Entity
  class Parameters
    # @param controller_params [ActionController::Parameters]
    def initialize(controller_params)
      @controller_params = controller_params
    end

    def update_entity
      ParametersHelper.prepare_params(
        @controller_params.require(:entity).permit(
          :name, :blurb, :summary, :website, :start_date, :end_date, :is_current,
          person_attributes: [:name_first, :name_middle, :name_last, :name_prefix, :name_suffix, :name_nick, :birthplace, :gender_id, :id],
          public_company_attributes: [:ticker, :id],
          school_attributes: [:is_private, :id],
          business_attributes: [:id, :annual_profit, :assets, :marketcap, :net_income]
        )
      )
    end

    def extension_def_ids
      if @controller_params.require(:entity).key?(:extension_def_ids)
        @controller_params.require(:entity)[:extension_def_ids].split(',').map(&:to_i)
      end
    end

    def new_entity(current_user)
      Utility.nilify_blank_vals(
        @controller_params
          .require(:entity)
          .permit(:name, :blurb, :primary_ext)
          .to_h
          .merge(last_user_id: User.derive_last_user_id_from(current_user))
          .with_indifferent_access
      )
    end

    def need_to_create_new_reference?
      !(using_existing_reference? || just_cleaning_up?)
    end

    def using_existing_reference?
      (existing_reference_params[:reference_id] || existing_reference_params[:document_id]).present?
    end

    def just_cleaning_up?
      existing_reference_params[:just_cleaning_up].present?
    end

    def document_attributes
      @document_attributes ||= @controller_params
                                 .require(:reference)
                                 .permit(:name, :url, :excerpt, :publication_date, :primary_source_document)
    end

    def submitted_with_regions?
      @controller_params.require(:entity).key?(:regions)
    end

    def region_numbers
      @controller_params.require(:entity)[:regions].delete_if(&:blank?).map(&:to_i)
    end

    private

    def existing_reference_params
      @existing_reference_params || @controller_params
                                      .require(:reference)
                                      .permit(:just_cleaning_up, :reference_id, :document_id).to_h.with_indifferent_access
    end
  end
end
