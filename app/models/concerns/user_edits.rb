# frozen_string_literal: true

# The namespace UserEdits contains:
#
# a module +ActiveUsers+ which add two class
# methods to user:
#   - active_user
#   - uniq_active_users
#
# A class +Edits+ for retrieving a list of edits
# done by the user
module UserEdits
  ACTIVE_USERS_PER_PAGE = 15
  ACTIVE_USERS_TIME_OPTIONS = {
    'week' => {
      'time' => 7.days.ago,
      'display' => 'in the past week'
    },
    'month' => {
      'time' => 30.days.ago,
      'display' => 'in the last 30 days'
    },
    '6_months' => {
      'time' => 180.days.ago,
      'display' => 'in the past 6 months'
    },
    'year' => {
      'time' =>  1.year.ago,
      'display' => 'in the past year'
    },
    'all_time' => {
      'time' => 100.years.ago,
      'display' =>  'since the beginning'
    }
  }.freeze

  ActiveUser = Struct.new(:user, :version) do
    delegate :username, :id, to: :user
    delegate :[], to: :version
  end

  module ActiveUsers
    extend ActiveSupport::Concern

    class_methods do # rubocop:disable Metrics/BlockLength
      def uniq_active_users(since: 30.days.ago)
        ApplicationVersion
          .where('versions.created_at >= ? AND whodunnit IS NOT NULL', since)
          .pluck(Arel.sql('distinct whodunnit'))
          .count
      end

      def active_users(since: 30.days.ago, page: 1, per_page: UserEdits::ACTIVE_USERS_PER_PAGE)
        versions = ApplicationVersion
                     .select(
                       Arel.sql(<<~SELECT)
                         whodunnit,
                         count(versions.id) as edits,
                         sum(case when event = 'create' and item_type = 'Entity' then 1 else 0 end) as entity_create_count,
                         sum(case when event = 'create' and item_type = 'Relationship' then 1 else 0 end) as relationship_create_count,
                         sum(case when event = 'create' then 1 else 0 end) as create_count,
                         sum(case when event = 'update' then 1 else 0 end) as update_count,
                         sum(case when event = 'soft_delete' then 1 when event = 'destroy' then 1 else 0 end) as delete_count
                       SELECT
                     )
                     .where('versions.created_at >= ? AND whodunnit IS NOT NULL', since)
                     .group('whodunnit')
                     .order('create_count desc')
                     .limit(per_page)
                     .offset((page.to_i - 1) * per_page)
                     .map(&:attributes)

        users = User.lookup_table_for versions.map { |v| v['whodunnit'] }

        Kaminari
          .paginate_array(versions, total_count: uniq_active_users(since: since))
          .page(page)
          .per(per_page)
          .map { |v| UserEdits::ActiveUser.new(users.fetch(v['whodunnit'].to_i), v) }
      end
    end
  end

  class Edits
    PER_PAGE = 20
    EDITABLE_TYPES = %w[Relationship Entity List Document].freeze
    UserEdit = Struct.new(:resource, :version, :action, :time)
    VersionsToModels = proc do |vs|
      vs.first.item_type.constantize.unscoped.find(vs.map(&:item_id).uniq)
    end
    ModelsToHashes = proc { |models| models.map { |m| [m.id, m] }.to_h }

    def initialize(user, page: 1, per_page: PER_PAGE)
      @user = user
      @page = page
      @per_page = per_page
    end

    # --> [EditedEntity]
    def edited_entities
      EditedEntity.recently_edited_entities(page: @page, user_id: @user.id, per_page: @per_page)
    end

    def recent_edits
      @recent_edits ||= ApplicationVersion
                          .where(whodunnit: @user.id, item_type: EDITABLE_TYPES)
                          .order(id: :desc)
                          .page(@page)
                          .per(PER_PAGE)
    end

    def recent_edits_presenter
      recent_edits.map do |v|
        UserEdit.new(
          record_lookup.dig(v.item_type, v.item_id),
          v,
          v.event.tr('_', ' ').capitalize,
          v.created_at.strftime('%B %e, %Y%l%p')
        )
      end
    end

    private

    def version_arel_table
      ApplicationVersion.arel_table
    end

    #  {
    #    'Entity' => { 123 => <Entity>, '345'=> <Entity> },
    #     Relationship' => { 456 => <Relationship> }
    #  }
    def record_lookup
      @record_lookup ||= recent_edits
                           .group_by(&:item_type)
                           .transform_values(&VersionsToModels)
                           .transform_values(&ModelsToHashes)
    end
  end
end
