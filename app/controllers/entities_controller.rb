class EntitiesController < ApplicationController
	before_filter :auth, except: [:relationships]
  before_action :set_entity, only: [:relationships, :fields, :update_fields, :edit_twitter, :add_twitter, :remove_twitter]

  def relationships
  end

  def fields
    @fields = JSON.dump(Field.all.map { |f| { value: f.name, tokens: f.display_name.split(/\s+/) } });
  end

  def update_fields
    fields = Hash[params[:names].zip(params[:values])]
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
      names = entities.map(&:name)
      dups = names.select do |name|
        names.select{ |n| n == name }.count > 1
      end

      data.each_with_index do |entity, i|
        if dups.include? entity[:name]
          entity[:name]
          info = entity[:blurb].present? ? entity[:blurb] : entity[:id].to_s
          # info = info.slice(0..20)
          data[i][:value] = entity[:name] + " (#{info})"
        end
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

  private

  def set_entity
    @entity = Entity.find(params[:id])
  end
end