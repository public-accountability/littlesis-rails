module TagableController
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [:tags]
  end

  # {
  #   tag: {
  #     ids: [1,2,3]
  #   }
  # }
  # POST /route(entity/list/etc)/:id/tags
  def tags
    klass_name = self.class.controller_name.classify
    tagable = klass_name.constantize.find(params[:id])
    tagable.update_tags(tag_ids)
    render json: { redirect: send("#{klass_name.downcase}_url", tagable) }, status: :accepted
  end


  private

  def tag_ids
    params.require(:tags).permit(:ids => [])[:ids].map(&:to_i)
  end
  
end
