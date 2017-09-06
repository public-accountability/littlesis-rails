class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action -> { check_permission('admin') }
  
  def edit
  end

  def create
    tag = Tag.new(tag_params)
    if tag.save
      flash[:notice] = "Tag successfully created"
    else
      flash[:alert] = "Error: #{tag.errors.full_messages.join('. ')}"
    end
    redirect_to admin_tags_path
  end

  def update
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :description, :restricted)
  end
end
