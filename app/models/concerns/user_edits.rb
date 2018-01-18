module UserEdits
  extend ActiveSupport::Concern

  ACTIVE_USERS_PER_PAGE = 15

  ActiveUser = Struct.new(:user, :version) do
    delegate :username, :id, to: :user
    delegate :[], to: :version
  end

  class_methods do
    def uniq_active_users(since: 30.days.ago)
      PaperTrail::Version
        .where("versions.created_at >= ? AND whodunnit IS NOT NULL", since)
        .pluck('distinct whodunnit')
        .count
    end

    def active_users(since: 30.days.ago, page: 1, per_page: UserEdits::ACTIVE_USERS_PER_PAGE)
      versions = PaperTrail::Version
                   .select(
                     <<~SELECT
                       whodunnit,
                       count(versions.id) as edits,
                       sum(case when event = 'create' then 1 else 0 end) as create_count,
                       sum(case when event = 'update' then 1 else 0 end) as update_count,
                       sum(case when event = 'soft_delete' then 1 when event = 'destroy' then 1 else 0 end) as delete_count
                       SELECT
                   )
                   .where("versions.created_at >= ? AND whodunnit IS NOT NULL", since)
                   .group("whodunnit")
                   .order('edits desc')
                   .limit(per_page)
                   .offset((page.to_i - 1) * per_page)
                   .map(&:attributes)

      users = User.lookup_table_for versions.map { |v| v['whodunnit'] }

      Kaminari
        .paginate_array(versions, total_count: uniq_active_users(since: since))
        .map { |v| ActiveUser.new(users.fetch(v['whodunnit'].to_i), v) }
    end
  end

  class Edits
    PER_PAGE = 20
    EDITABLE_TYPES = %w[Relationship Entity List Document].freeze
    UserEdit = Struct.new(:resource, :version, :action, :time)
    VersionsToModels = proc { |vs| vs.first.item_type.constantize.unscoped.find(vs.map(&:item_id).uniq) }
    ModelsToHashes = proc { |models| models.map { |m| [m.id, m] }.to_h }

    def initialize(user, page: 1)
      @user = user
      @page = page
    end

    def recent_edits
      @recent_edits ||= PaperTrail::Version
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

    #  {
    #    'Entity' => { 123 => <Entity>, '345'=> <Entity> },
    #     Relationship' => { 456 => <Relationship> }
    #  }
    def record_lookup
      @record_lookup ||= recent_edits
                       .group_by { |v| v.item_type }
                       .transform_values(&VersionsToModels)
                       .transform_values(&ModelsToHashes)
    end
  end

  
end
