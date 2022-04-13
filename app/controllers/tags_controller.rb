# frozen_string_literal: true

# Tagable categories: entities, lists, relationships. See: `Tagable.categories`
class TagsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :edits]
  before_action -> { check_ability(:create_tag) }, except: [:index, :show, :edits, :tag_request]
  before_action :set_tag, only: [:edit, :update, :destroy, :show, :edits]
  before_action :set_tags, only: [:index]
  before_action :set_tagables, only: [:show]

  def index; end

  # the 'tag homepage'
  def show; end

  def edit; end

  def create
    tag = Tag.new(tag_params)
    if tag.save
      flash[:notice] = "Tag successfully created"
    else
      flash[:errors] = tag.errors.full_messages
    end
    redirect_to admin_tags_path
  end

  def update
    if @tag.update(tag_params)
      flash[:notice] = "Tag successfully updated"
      if @tag.saved_change_to_name?
        flash[:alert] = "Please tell the site administrator to restart the web application"
      end
      redirect_to admin_tags_path
    else
      flash[:alert] = "Error: #{@tag.errors.full_messages.join('. ')}"
      redirect_to edit_tag_path(@tag)
    end
  end

  def destroy
    check_ability :edit_destructively
    @tag.destroy
    redirect_to admin_tags_path, notice: 'The tag has been removed'
  end

  def edits
    @recent_edits = @tag.recent_edits_for_homepage page: params.fetch(:page, 1)
  end

  # COMPLEX ACTIONS

  def tag_request
    if request.post?
      email_parameters = params.permit('tag_name', 'tag_description', 'tag_additional').to_h
      NotificationMailer.tag_request_email(current_user, email_parameters).deliver_later
      return redirect_to home_dashboard_path, notice: 'Your request for a new tag has been submitted. Thank you!'
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :description, :restricted)
  end

  def set_tagables
    @tagable_category = params[:tagable_category] || Entity.category_str
    @tagable_subtypes = @tagable_category == Entity.category_str ? %w[Person Org] : [nil]
    @tagables = @tag.tagables_for_homepage(@tagable_category, **page_params)
  end

  # for the tagable category "entities",
  # tag#tagables_for_homepage requires two params: "person_page" and "org_page"
  # all other categories use the just the param "page"
  def page_params
    if @tagable_category == 'entities'
      { person_page: params.fetch(:person_page, 1), org_page: params.fetch(:org_page, 1) }
    else
      { page: params.fetch(:page, 1) }
    end
  end

  def set_tag
    @tag = Tag.get!(params[:id])
  end

  def set_tags
    @tags = Tag.all.order(:name)
  end
end
