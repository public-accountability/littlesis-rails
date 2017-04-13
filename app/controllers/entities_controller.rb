class EntitiesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :relationships, :political, :contributions, :references]
  before_action :set_entity, except: [:new, :create, :search_by_name, :search_field_names, :show]
  before_action :set_entity_with_eager_loading, only: [:show]
  before_action :set_current_user, only: [:show, :political, :match_donations]
  before_action :importers_only, only: [:match_donation, :match_donations, :review_donations, :match_ny_donations, :review_ny_donations]

  def show
    @similar_entities = @entity.similar_entities
  end

  def new
  end

  def create
    @entity = Entity.new(new_entity_params.merge(last_user_id: current_user.sf_guard_user_id))

    if @entity.save # successfully created entity
      params[:types].each { |type| @entity.add_extension(type) } if params[:types].present?

      if add_relationship_page?
        render json: {
                 status: 'OK',
                 entity: {
                   id: @entity.id,
                   name: @entity.name,
                   description: @entity.blurb,
                   url: @entity.legacy_url,
                   primary_type: @entity.primary_ext
                 }
               }
      else
        redirect_to @entity.legacy_url("edit")
      end

    else # encounted error

      if add_relationship_page?
        render json: { status: 'ERROR', errors: @entity.errors.messages }
      else
        render action: 'new'
      end
      
    end
  end

  def edit
    set_entity_references
  end

  # this methods follows a similar pattern to relationships_controller#update
  def update
    if need_to_create_new_reference
      @reference = Reference.new(reference_params.merge(object_id: @entity.id, object_model: "Entity"))
      unless @reference.validate_before_create.empty?
        @reference_error_message = "The reference is not valid"
        set_entity_references
        return render :edit
      end
    end
    
    if @entity.update_attributes prepare_update_params(update_entity_params)
      @entity.update_extension_records(extension_def_ids)
      @reference.save unless @reference.nil? # save the reference
      redirect_to @entity.legacy_url
    else
      set_entity_references
      render :edit
    end
  end

  def relationships
  end

  def add_relationship
    @relationship = Relationship.new
    @reference = Reference.new
  end

  def political
  end

  def references
    refs = @entity.all_references
    @reference_count = refs.size
    @references = Kaminari.paginate_array(refs).page(params[:page]).per(25)
  end

  # ------------------------------ #
  # Open Secrets Donation Matching #
  # ------------------------------ #

  def match_donations
  end

  def review_donations
  end

  def match_donation
    params[:payload].each do |donation_id|
      match = OsMatch.find_or_create_by(os_donation_id: donation_id, donor_id: params[:id])
      match.update(matched_by: current_user.id)
    end
    @entity.update(last_user_id: current_user.sf_guard_user.id)
    @entity.delay.clear_legacy_cache(request.host)
    render json: { status: 'ok' }
  end

  def unmatch_donation
    check_permission 'importer'
    params[:payload].each do |os_match_id|
      OsMatch.find(os_match_id).destroy
    end
    @entity.update(last_user_id: current_user.sf_guard_user.id)
    @entity.delay.clear_legacy_cache(request.host)
    render json: { status: 'ok' }
  end

  def contributions
    render json: @entity.contribution_info
  end

  def potential_contributions
    render json: @entity.potential_contributions
  end

  # ------------------------------ #
  # NYS Donation Matching          #
  # ------------------------------ #

  def match_ny_donations
  end

  def review_ny_donations
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
		entities = Entity.search(
      "@(#{fields}) #{q}", 
      per_page: num, 
      match_mode: :extended, 
      with: { is_deleted: false },
      select: "*, weight() * (link_count + 1) AS link_weight",
      order: "link_weight DESC"
    )
		data = entities.collect { |e| { value: e.name, name: e.name, id: e.id, blurb: e.blurb, url: relationships_entity_path(e) } }

    if list_id = params[:exclude_list]
      entity_ids = ListEntity.where(list_id: list_id).pluck(:entity_id)
      data.delete_if { |e| entity_ids.include?(e[:id]) }
    end

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
    check_permission 'importer'
    @q = (params[:q] or @entity.name)
    page = (params[:page] or 1).to_i
    @articles = @entity.articles
    selected_urls = @articles.map(&:url)
    engine = GoogleSearch.new(Lilsis::Application.config.google_custom_search_engine_id)
    @results = engine.search(@q, page).to_a + engine.search(@q, page + 1).to_a
    @results.select! { |r| !selected_urls.include?(r['link']) }
    @queue_count = entity_queue_count(:find_articles)
  end

  def import_articles
    check_permission 'importer'
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

    # permanently remove entity from queue
    if selected_ids.count == 0
      skip_queue_entity(:find_articles, @entity.id)
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

  def new_article
    @article = Article.new
  end

  def create_article
    @article = Article.new(article_params)
    @article.created_by_user_id = current_user.id
    @article.article_entities.build(entity_id: @entity.id, is_featured: true)

    if @article.save
      redirect_to articles_entity_path(@entity), notice: 'Article was successfully created.'
    else
      render action: 'new_article'
    end
  end

  def find_merges
    check_permission 'merger'
    
    if @entity.person?
      person = @entity.person
      @matches = Entity.search("@(name,aliases) #{person.name_last} #{person.name_first}", per_page: 5, match_mode: :extended, with: { is_deleted: false }).select { |e| e.id != @entity.id }
    elsif @entity.org?
      @matches = EntityMatcher.by_org_name(@entity.name).select { |e| e.id != @entity.id }
    end

    if (@q = params[:q]).present?
      page = params[:page]
      num = params[:num]
      @results = Entity.search("@(name,aliases) #{@q}", per_page: num, page: page, match_mode: :extended, with: { is_deleted: false })
      @results.select! { |e| e.id != @entity.id }
    end
  end

  def merge
    check_permission 'merger'

    @keep = Entity.find(params[:keep_id])
    EntityMerger.merge_all(@keep, @entity)
    @entity.soft_delete
    @keep.clear_cache(request.host)

    redirect_to @keep.legacy_url, notice: 'Entities were successfully merged.'
  end

  def refresh
    check_permission 'admin'
    @entity.clear_cache(request.host)
    redirect_to @entity.legacy_url
  end

  def images
    check_permission 'contributor'
  end

  def feature_image
    image = Image.find(params[:image_id])
    image.feature
    redirect_to images_entity_path(@entity)
  end

  def remove_image
    image = Image.find(params[:image_id])
    image.destroy
    redirect_to images_entity_path(@entity)
  end

  def new_image
    @image = Image.new
    @image.entity = @entity
  end

  def upload_image
    if uploaded = image_params[:file]
      filename = Image.random_filename(File.extname(uploaded.original_filename))      
      src_path = Rails.root.join('tmp', filename).to_s
      open(src_path, 'wb') do |file|
        file.write(uploaded.read)
      end
    else
      src_path = image_params[:url]
    end

    @image = Image.new_from_url(src_path)
    @image.entity = @entity
    @image.is_free = image_params[:is_free]
    @image.title = image_params[:title]
    @image.caption = image_params[:caption]

    if @image.save
      @image.feature if image_params[:is_featured]
      redirect_to images_entity_path(@entity), notice: 'Image was successfully created.'
    else
      render action: 'new_image'
    end
  end

  private

  def set_current_user
    @current_user = current_user
  end

  def set_entity_with_eager_loading
    @entity = Entity.includes(:aliases, list_entities: [:list]).find(params[:id])
  end

  def set_entity
    @entity = Entity.find(params[:id])
  end

  def set_entity_references
    @references = @entity.references.order('updated_at desc').limit(10)
  end

  def need_to_create_new_reference
    existing_reference_params['reference_id'].blank? && existing_reference_params['just_cleaning_up'].blank?
  end

  def article_params
    params.require(:article).permit(
      :title, :url, :snippet, :published_at
    )
  end

  def image_params
    params.require(:image).permit(
      :file, :title, :caption, :url, :is_free, :is_featured
    )
  end

  def reference_params
    params.require(:reference).permit(:name, :source, :source_detail, :publication_date, :ref_type)
  end

  def existing_reference_params
    params.require(:reference).permit(:just_cleaning_up, :reference_id)
  end

  def update_entity_params
    params.require(:entity).permit(
      :name, :blurb, :summary, :notes, :website, :start_date, :end_date, :is_current, :is_deleted,
      person_attributes: [:name_first, :name_middle, :name_last, :name_prefix, :name_suffix, :name_nick, :birthplace, :gender_id, :id ],
      public_company_attributes: [:ticker, :id],
      school_attributes: [:is_private, :id]
    )
  end

  # output: [Int] or nil
  def extension_def_ids
    if params.require(:entity).key?(:extension_def_ids)
      return params.require(:entity).fetch(:extension_def_ids).split(',').map(&:to_i)
    end
  end

  def new_entity_params
    params.require(:entity).permit(:name, :blurb, :primary_ext)
  end

  def add_relationship_page?
    params[:add_relationship_page].present?
  end

  def importers_only
    check_permission 'importer'
  end
end

