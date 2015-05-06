class TopicsController < ApplicationController
  before_action :auth, except: [:show]
<<<<<<< HEAD
  before_action :require_admin, except: [:show]
=======
  before_action :admins_only, except: [:show]
>>>>>>> master
  before_action :set_topic, only: [:show, :edit, :update, :destroy, :new_element, :add_element]

  class ElementType
    attr_accessor :param, :display_name, :klass

    def initialize(param, display_name, klass)
      @param = param
      @display_name = display_name
      @klass = klass
    end
  end

  ELEMENT_TYPES = {
    list: ElementType.new('list', 'List', List),
    map: ElementType.new('map', 'Map', NetworkMap),
    article: ElementType.new('article', 'Article', Article)
  }

<<<<<<< HEAD
  def require_admin
    check_permission('admin')
  end

=======
>>>>>>> master
  def include_all
    @topic
  end

  # GET /topics
  def index
    @topics = Topic.all
  end

  # GET /topics/fracking
  def show
    @topic.lists.includes(:list_entities)
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /topics/fracking/edit
  def edit
  end

  # POST /topics
  def create
    @topic = Topic.new(topic_params)

    if @topic.save
      redirect_to @topic, notice: 'Topic was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /topics/fracking
  def update
    if @topic.update(topic_params)
      redirect_to @topic, notice: 'Topic was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /topics/fracking
  def destroy
    @topic.destroy
    redirect_to topics_url, notice: 'Topic was successfully destroyed.'
  end

  # GET /topics/fracking/new_element
  def new_element
    @types = ELEMENT_TYPES

    @type = ELEMENT_TYPES[params.fetch(:type, 'list').to_sym]
    @q = params[:q] || nil

    if @q.present? and @type.present?
      send(:"find_#{@type.param}")
    end
  end

  def find_list
    @results = List.search(@q).select { |l| !@topic.list_ids.include?(l.id) }
  end

  def find_network_map
    @results = NetworkMap.search(@q)
  end

  # POST /topics/fracking/add_element
  def add_element
    type = ELEMENT_TYPES[params[:type].to_sym]
    element_ids = params[:element_ids]

    Topic.transaction do
      element_ids.each do |eid|
        element = type.klass.find(eid)
        @topic.send(:"#{type.param.pluralize}") << element
      end
    end

    redirect_to topic_path(@topic)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      @topic = Topic.find_by_slug(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def topic_params
      params.require(:topic).permit(:name, :slug, :description)
    end
end
