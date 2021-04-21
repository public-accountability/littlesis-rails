# frozen_string_literal: true

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
    tagable = self.class.controller_name.classify.constantize.find(params[:id])
    check_tagable_access(tagable)
    tagable.update_tags(tag_ids, admin: current_user.admin?)

    respond_to do |format|
      format.html { redirect_to after_tags_redirect_url(tagable) }
      format.js { render(json: { redirect: after_tags_redirect_url(tagable) }, status: :accepted) }
    end
  end

  protected

  # It defaults to the tagable_url i.e. entity_url
  # Override this method in the controller to change
  # the url that the client should be redirected to
  def after_tags_redirect_url(tagable)
    if tagable.is_a? Entity
      concretize_entity_url(tagable)
    else
      send("#{self.class.controller_name.classify.downcase}_url", tagable)
    end
  end

  # Override this method in the controller
  # to restrict access to the /tags route
  # beyond authenticate_user!
  def check_tagable_access(tagable)
  end

  private

  def tag_ids
    params.require(:tags).permit(:ids => [])[:ids].map(&:to_i)
  end
end
