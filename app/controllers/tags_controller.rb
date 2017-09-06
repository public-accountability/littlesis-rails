class TagsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action -> { check_permission('admin') }, except: [:show]
  before_action :set_tag, only: [:edit, :update, :destroy]

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
    if @tag.update(tag_params)
      flash[:notice] = "Tag successfully updated"
      redirect_to admin_tags_path
    else
      flash[:alert] = "Error: #{@tag.errors.full_messages.join('. ')}"
      redirect_to edit_tag_path(@tag)
    end
  end

  def destroy
    @tag.destroy
    redirect_to admin_tags_path, notice: 'The tag has been removed'
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :description, :restricted)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
