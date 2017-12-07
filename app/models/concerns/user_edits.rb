module UserEdits
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
