class TagsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action -> { check_permission('admin') }, except: [:index, :show, :tag_request]
  before_action :set_tag, only: [:edit, :update, :destroy, :show]
  before_action :set_tags, only: [:index]
  before_action :set_tagables, only: [:show]


  def index; end

  def show; end

  def edit; end

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

  def edits
  end

  # COMPLEX ACTIONS

  def tag_request
    if request.post?
      NotificationMailer.tag_request_email(current_user, params).deliver_later
      return redirect_to home_dashboard_path, notice: "Your request for a new tag has been submitted. Thank you!"
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :description, :restricted)
  end

  def set_tagables
    @tagable_category = params[:tagable_category] || Entity.category_str
    @tagable_subtypes = @tagable_category == Entity.category_str ? %w[Person Org] : [nil]
    page = params[:page] || 1
    @tagables = @tag.tagables_for_homepage(@tagable_category, page)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def set_tags
    @tags = Tag.all.order(:name)
  end
end
