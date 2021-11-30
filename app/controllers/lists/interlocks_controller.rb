# frozen_string_literal: true

module Lists
  class InterlocksController < ApplicationController
    include ListPermissions

    OPTIONS = {
      category_ids: [Relationship::POSITION_CATEGORY, Relationship::MEMBERSHIP_CATEGORY],
      order: 2,
      degree1_ext: 'Person'
    }.freeze

    before_action :set_list
    before_action :set_permissions
    before_action -> { check_access(:viewable) }

    def index
      entities = ListInterlocksQuery.new(@list).run
      @companies = entities.select { |e| e.types.include?('Business') }
      @govt_bodies = entities.select { |e| e.types.include?('Government Body') }
      @others = entities - @companies - @govt_bodies
    end

    # interlocks tag
    def show
      options = get_options(params.fetch(:interlocks_tab))
      results = @list.interlocks(options).page(page).per(page_number)
      count = @list.interlocks_count(options)
      @interlocks = Kaminari.paginate_array(results.to_a, total_count: count).page(page).per(page_number)

      render params.fetch(:interlocks_tab)
    end

    private

    def get_options(tab)
      case tab
      when 'companies'
        OPTIONS.merge(degree2_type: 'Business')
      when 'government'
        OPTIONS.merge(degree2_type: 'GovernmentBody')
      when 'other_orgs'
        OPTIONS.merge(exclude_degree2_types: %w[Business GovernmentBody])
      when 'giving'
        OPTIONS.merge(category_ids: [Relationship::DONATION_CATEGORY], sort: :amount)
      when 'funding'
        OPTIONS.merge(category_ids: [Relationship::DONATION_CATEGORY], order: 1, sort: :amount)
      end
    end

    def set_list
      @list = List.find(params[:list_id])
    end

    def page
      @page ||= params.fetch(:page, 1)
    end

    def page_number
      @page_number ||= params.fetch(:num, 20)
    end
  end
end
