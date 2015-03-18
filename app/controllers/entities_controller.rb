class EntitiesController < ApplicationController
	before_filter :auth, except: [:relationships]
  before_action :set_entity, only: [:relationships, :fields, :update_fields, :edit_twitter, :add_twitter, :remove_twitter, :find_articles, :import_articles, :articles, :remove_article]

  def relationships
  end

  def fields
    @fields = JSON.dump(Field.all.map { |f| { value: f.name, tokens: f.display_name.split(/\s+/) } });
  end

  def update_fields
    if params[:names].nil? and params[:values].nil?
      fields = {}
    else
      fields = Hash[params[:names].zip(params[:values])]
    end
    @entity.update_fields(fields)
    Field.delete_unused
    redirect_to fields_entity_path(@entity)
  end

	def search_by_name
		data = []
		q = params[:q]
    num = params.fetch(:num, 10)
    fields = params[:desc] ? 'name,aliases,blurb' : 'name,aliases'
		entities = Entity.search "@(#{fields}) #{q}", per_page: num, match_mode: :extended, with: { is_deleted: false }
		data = entities.collect { |e| { value: e.name, name: e.name, id: e.id, blurb: e.blurb } }

    if params[:with_ids]
      dups = entities.group_by(&:name).select { |name, ary| ary.count > 1 }.keys
      data.map! do |hash|
        if dups.include?(hash[:name])
          info = hash[:blurb].present? ? hash[:blurb] : hash[:id].to_s
          hash[:value] = hash[:name] + " (#{info})"
        end
        hash
      end      
    end

		render json: data
	end

  def search_field_names
    q = params[:q]
    num = params.fetch(:num, 10)
    fields = Field.search(q, per_page: num, match_mode: :extended)
    render json: fields.map { |f| f.name }.sort
  end

  def edit_twitter
    check_permission 'bulker'
    tw = Lilsis::Application.twitter

    @accounts = tw.users(Array(@entity.twitter_ids).map(&:to_i))
    @matches = tw.user_search(@entity.name_without_initials)
    @matches.delete_if { |match| Array(@accounts).map(&:id).include? match.id }

    @next_entity = TwitterQueue.random_entity
    @list = List.where(id: params[:list_id]).first
  end

  def add_twitter
    check_permission 'bulker'
    if params[:twitter_id].present?
      key = @entity.external_keys.where(
        domain_id: Domain::TWITTER_ID,
        external_id: params[:twitter_id]
      ).first_or_create
    end

    list = List.where(id: params[:list_id]).first
      
    if list.present?
      redirect_to next_twitter_list_path(list)
    else
      redirect_to edit_twitter_entity_path(@entity)
    end
  end

  def remove_twitter
    check_permission 'bulker'
    if params[:twitter_id]
      key = @entity.external_keys.where(
        domain_id: Domain::TWITTER_ID,
        external_id: params[:twitter_id]
      ).first

      key.delete if key.present?
    end

    list = List.where(id: params[:list_id]).first
      
    if list.present?
      redirect_to next_twitter_list_path(list)
    else
      redirect_to edit_twitter_entity_path(@entity)
    end
  end

  def next_twitter
    check_permission 'bulker'
    @entity = TwitterQueue.random_entity

    redirect_to edit_twitter_entity_path(@entity)
  end

  def articles
  end

  def find_articles
    @q = (params[:q] or @entity.name)
    page = (params[:page] or 1).to_i
    @articles = @entity.articles
    selected_urls = @articles.map(&:url)
    engine = GoogleSearch.new(Lilsis::Application.config.google_custom_news_search_engine_id)
    @results = engine.search(@q, page).to_a + engine.search(@q, page + 1).to_a
    @results.select! { |r| !selected_urls.include?(r['link']) }
    @queue_count = entity_queue_count(:find_articles)
  end

  def import_articles
    selected_ids = params.keys.map(&:to_s).select { |k| k.match(/^selected-/) }.map { |k| k.split('-').last }.map(&:to_i)
    selected_ids.each do |i|
      snippet = CGI.unescapeHTML(params[:snippet][i])
      published_at = nil

      if date = snippet.match(/^\w{3}\s+\d+,\s+\d{4}/)
        published_at = date[0]
        snippet.gsub!(/^\w{3}\s+\d+,\s+\d{4}\s+\.\.\.\s+/, '')
      end

      @entity.add_article({
        title: CGI.unescapeHTML(params[:title][i]),
        url: CGI.unescapeHTML(params[:url][i]),
        snippet: snippet,
        published_at: published_at,
        created_by_user_id: current_user.id
      }, featured = true)
    end

    @queue_count = entity_queue_count(:find_articles)
    if @queue_count > 0
      if params[:submit_stay]
        redirect_to find_articles_entity_path(@entity.id)
      else
        redirect_to find_articles_entity_path(next_entity_in_queue(:find_articles))
      end
    else
      redirect_to articles_entity_path(@entity)
    end
  end

  def remove_article
    ae = ArticleEntity.find_by(entity_id: @entity.id, article_id: params[:article_id])
    ae.destroy
    redirect_to articles_entity_path(@entity)
  end

  private

  def set_entity
    @entity = Entity.find(params[:id])
  end
end