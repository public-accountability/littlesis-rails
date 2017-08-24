module TagableController
  

  # {
  #   tag: {
  #     ids: [1,2,3]
  #   }
  # }
  # POST /route(entity/list/etc)/:id/tags
  def tags
    klass_name = self.class.controller_name.classify
    tagable = klass_name.constantize.find(params[:id])
    
    server_tag_ids = tagable.tags.map { |t| t[:id] }.to_set
    client_tag_ids = tag_ids.to_set
    actions = Tag.parse_update_actions(client_tag_ids, server_tag_ids)

    actions[:remove].each do |tag_id|
      tagable.taggings.find_by_tag_id(tag_id).destroy
    end

    actions[:add].each do |tag_id|
      tagable.tag(tag_id)
    end

    head :created
    #TODO: redirect_to tagable.after_tagable_create_path
  end


  private

  def tag_ids
    params.require(:tag).permit(:ids => [])[:ids].map(&:to_i)
  end
  
end
