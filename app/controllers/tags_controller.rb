class TagsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action -> { check_permission('admin') }, except: [:index, :show, :tag_request]
  before_action :set_tag, only: [:edit, :update, :destroy, :show]
  before_action :set_tags, only: [:index]
  before_action :set_tagables, only: [:show]

  TAGABLE_PAGINATION_LIMIT = 20

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
    # TODO(ag|Thu 14 Sep 2017):
    # consider using dynamic methods to create actions for each tagable class
    # (corresponding to `tagable_category` string)
    # instead of pulling `tagable_category` from params as here
    @tagable_category = params[:tagable_category] || 'entities'
    @tagables = @tag
                .send(@tagable_category.to_sym)
                .order(updated_at: :desc)
                .page(params[:page])
                .per(TAGABLE_PAGINATION_LIMIT)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def set_tags
    @tags = Tag.all.order(:name)
  end
end
