class TopicsController < ApplicationController
  before_action :auth, except: [:show]
  before_action :admins_only, except: [:show]
  before_action :set_topic, only: [:show, :edit, :update, :destroy, :new_elements, :add_elements, :remove_element]

  class ElementType
    attr_accessor :param, :display_name, :klass, :join_klass, :join_field

    def initialize(param, display_name, klass, join_klass, join_field)
      @param = param
      @display_name = display_name
      @klass = klass
      @join_klass = join_klass
      @join_field = join_field
    end
  end

  ELEMENT_TYPES = {
    list: ElementType.new('list', 'List', List, TopicList, :list_id),
    map: ElementType.new('map', 'Map', NetworkMap, TopicMap, :map_id),
    industry: ElementType.new('industry', 'Industry', Industry, TopicIndustry, :industry_id),
    # article: ElementType.new('article', 'Article', Article, TopicArticle, :article_id)
  }

  def clear_cache
    @topic.clear_cache(request.host)
  end

  # GET /topics
  def index
    @topics = Topic.all
  end

  # GET /topics/fracking
  def show
    @topic = Topic.where(id: @topic.id).includes(lists: :entities).first
    @table = TopicDatatable.new(@topic)
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
      clear_cache
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
  def new_elements
    @types = ELEMENT_TYPES

    @type = ELEMENT_TYPES[params.fetch(:type, 'list').to_sym]
    @q = params[:q] || nil

    if @q.present? and @type.present?
      send(:"find_#{@type.param}")
    end
  end

  def find_list
    @results = List.search(
      Riddle::Query.escape(@q),
      with: { is_deleted: 0, is_admin: 0, is_network: 0 }
    ).select { |l| !@topic.list_ids.include?(l.id) }
  end

  def find_map
    @results = NetworkMap.search(
      Riddle::Query.escape(@q),
      with: { visible_to_user_ids: [0] }
    ).select { |m| !@topic.map_ids.include?(m.id) }
  end

  def find_industry
    @results = Industry.search(
      Riddle::Query.escape(@q)
    ).select { |i| !@topic.industry_ids.include?(i.id) }
  end

  # POST /topics/fracking/add_element
  def add_elements
    type = ELEMENT_TYPES[params[:type].to_sym]
    element_ids = params[:element_ids]

    Topic.transaction do
      element_ids.each do |eid|
        element = type.klass.find(eid)
        @topic.send(:"#{type.param.pluralize}") << element
      end
    end

    clear_cache

    display_name = element_ids.count > 0 ? type.display_name.pluralize : type.display_name
    redirect_to topic_path(@topic), notice: type.display_name + ' successfully added to this topic.'
  end

  def remove_element
    type = ELEMENT_TYPES[params[:type].to_sym]
    element_id = params[:element_id]

    clear_cache

    type.join_klass.find_by(topic_id: @topic.id, type.join_field => element_id).destroy
    redirect_to topic_path(@topic), notice: type.display_name + ' was successfully removed from this topic.'
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
