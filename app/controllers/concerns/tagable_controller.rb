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
    tagable.update_tags(tag_ids)
    redirect_to send("#{klass_name.downcase}_path", tagable)
  end


  private

  def tag_ids
    params.require(:tag).permit(:ids => [])[:ids].map(&:to_i)
  end
  
end
