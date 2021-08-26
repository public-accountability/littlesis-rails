# frozen_string_literal: true

module Lists
  class InterlocksController < ApplicationController
    include ListPermissions

    OPTIONS = {
      category_ids: [RelationshipCategory.name_to_id[:position], RelationshipCategory.name_to_id[:membership]],
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

    def show # rubocop:disable Metrics/AbcSize
      @results = @list.interlocks(options).page(page).per(page_number)

      Kaminari.paginate_array(
        @results.to_a,
        total_count: @list.interlocks_count(options)
      ).page(page).per(page_number)

      @interlocks = interlocks_results(options)

      render params.fetch(:interlocks_tab)
    end

    private

    def interlocks_results(options)
      results = @list.interlocks(options).page(page).per(page_number)
      count = @list.interlocks_count(options)
      Kaminari.paginate_array(results.to_a, total_count: count).page(page).per(page_number)
    end

    def options # rubocop:disable Metrics/MethodLength
      @options ||= case params.fetch(:interlocks_tab)
                   when 'companies'
                     OPTIONS.merge(degree2_type: 'Business')
                   when 'government'
                     OPTIONS.merge(degree2_type: 'GovernmentBody')
                   when 'other_orgs'
                     OPTIONS.merge(exclude_degree2_types: %w[Business GovernmentBody])
                   when 'giving'
                     OPTIONS.merge(category_ids: [RelationshipCategory.name_to_id[:donation]], sort: :amount)
                   when 'funding'
                     OPTIONS.merge(category_ids: [RelationshipCategory.name_to_id[:donation]], order: 1,
                                   sort: :amount)
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
