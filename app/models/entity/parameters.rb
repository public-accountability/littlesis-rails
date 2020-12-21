# frozen_string_literal: true

class Entity
  class Parameters
    def initialize(controller_params) # ActionController::Parameters
      @controller_params = controller_params
    end

    def update_entity
      @controller_params.require(:entity).permit(
        :name, :blurb, :summary, :website, :start_date, :end_date, :is_current,
        person_attributes: [:name_first, :name_middle, :name_last, :name_prefix, :name_suffix, :name_nick, :birthplace, :gender_id, :id],
        public_company_attributes: [:ticker, :id],
        school_attributes: [:is_private, :id],
        business_attributes: [:id, :annual_profit, :assets, :marketcap, :net_income]
      )
    end

    def extension_def_ids
      if @controller_params.require(:entity).key?(:extension_def_ids)
        @controller_params.require(:entity)[:extension_def_ids].split(',').map(&:to_i)
      end
    end

    def new_entity(current_user)
      LsHash.new(@controller_params.require(:entity).permit(:name, :blurb, :primary_ext).to_h)
        .with_last_user(current_user)
        .nilify_blank_vals
    end
  end
end
