# frozen_string_literal: true

class EditablePagesController < ApplicationController
  before_action :authenticate_user!, except: [:display, :index]
  before_action :admins_only, except: [:display, :index]
  before_action :set_page, only: [:display, :edit]

  helper_method :markdown, :editable_page_path

  class RenderWithTableClass < Redcarpet::Render::HTML
    def table(thead, tbody)
      <<~HTML
        <table class='table'>
          <thead>#{thead}</thead>
          <tbody>#{tbody}</tbody>
        </table>
      HTML
    end
  end

  MARKDOWN = Redcarpet::Markdown.new(RenderWithTableClass,
                                     autolink: true, fenced_code_blocks: true, tables: true)

  # GET /NAMESAPCE/:page_name
  def display
  end

  def edit
  end

  # GET /NAMESPACE
  def index
    @page = self.class.page_model.find_by(name: 'index')
    @markdown =
      if @page && !@page.markdown.nil?
        markdown(@page.markdown)
      else
        markdown("The #{self.class.namespace} page named 'index' will be used as the front page.")
      end
  end

  # GET /NAMESPACE/new
  def new
    @page = self.class.page_model.new
  end

  # GET /NAMESPACE/pages
  # Note: this returns all pages in (using the .all method)
  # By default this will render the template editable_pages/pages.html.erb
  def pages
    @pages = self.class.page_model
      .select('name, title, id, updated_at, created_at, last_user_id').all
  end

  # POST /NAMESPACE
  def create
    @page = self.class.page_model.new(new_page_params)
    if @page.save
      redirect_to send("#{self.class.namespace}_edit_path", page_name: @page.name)
    else
      render :new
    end
  end

  # PATCH /NAMESPACE/:id
  def update
    @page = self.class.page_model.find(params[:id])
    if @page.update(update_params)
      redirect_to send("#{self.class.namespace}_display_url", page_name: @page.name)
    else
      render :edit
    end
  end

  ## Class Configuration ##

  def self.namespace(val = nil)
    @_namespace = val unless val.nil?
    @_namespace
  end

  def self.page_model(model = nil)
    unless model.nil?
      @page_model = model unless model.nil?
      @model_param = model.name.underscore
    end

    @page_model
  end

  protected

  def markdown(data)
    self.class.const_get(:MARKDOWN).render(data || '')
  end

  def editable_page_path(name, action = nil)
    base = "/#{self.class.namespace}/#{name}"
    return base if action.nil?

    "#{base}/#{action}"
  end

  private

  def set_page
    raise Exceptions::NotFoundError if page_name.blank?

    @page = self.class.page_model.find_by(name: page_name)
    raise Exceptions::NotFoundError if @page.nil?
  end

  def page_name
    name = params[:page_name]
    self.class.page_model.pagify_name(name) if name.present?
  end

  def update_params
    params.require(model_param).permit(:title, :markdown).merge(last_user_id: current_user.id)
  end

  def new_page_params
    params.require(model_param).permit(:name, :title).merge(last_user_id: current_user.id)
  end

  def model_param
    self.class.instance_variable_get(:@model_param)
  end
end
