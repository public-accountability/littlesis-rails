class EditablePagesController < ApplicationController
  before_action :authenticate_user!, except: [:display, :index]
  before_action :admins_only, only: [:new, :create, :edit, :update]
  before_action :set_page, only: [:display, :edit]

  helper_method :markdown

  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                     autolink: true, fenced_code_blocks: true, tables: true)

  # GET /NAMESAPCE/:page_name
  def display
  end

  def edit
  end

  # GET /NAMESPACE
  def index
    @page = self.class.page_model.find_by_name('index')
    if @page && !@page.markdown.nil?
      @markdown = markdown(@page.markdown)
    else
      @markdown = markdown("The toolkit page named 'index' will be used as the front page.")
    end
  end

  # GET /toolkit/new
  def new
    @page = self.class.page_model.new
  end

  # POST /toolkit
  def create
    @page = self.class.page_model.new(new_page_params)
    if @page.save
      redirect_to send("#{self.class.namespace}_edit_path", page_name: @page.name)
    else
      render :new
    end
  end

  # PATCH /toolkit/:id
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
    self.class.const_get(:MARKDOWN).render(data)
  end

  private

  def set_page
    raise Exceptions::NotFoundError if page_name.blank?
    @page = self.class.page_model.find_by_name(page_name)
    raise Exceptions::NotFoundError if @page.nil?
  end

  def page_name
    name = params[:page_name]
    self.class.page_model.pagify_name(name) unless name.blank?
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


