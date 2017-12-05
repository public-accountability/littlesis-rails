module UserEdits
  class Edits
    PER_PAGE = 20
    EDITABLE_TYPES = %w[Relationship Entity List Document].freeze
    UserEdit = Struct.new(:resource, :version, :action, :time)
    VersionsToModel = proc { |vs| vs.first.item_type.constantize.unscoped.find(vs.map(&:item_id).uniq) }

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
          ar_lookup.dig(v.item_type, v.item_id),
          v,
          v.event.capitalize,
          v.created_at.strftime('%B %e, %Y%l%p')
        )
      end
    end

    private

    #  {
    #    'Entity' => { 123 => <Entity>, '345'=> <Entity> },
    #     Relationship' => { 456 => <Relationship> }
    #  }
    def ar_lookup
      @ar_lookup ||= recent_edits
                       .group_by { |v| v.item_type }
                       .transform_values(&VersionsToModel)
                       .transform_values { |models| models.map { |m| [m.id, m] }.to_h }
    end
  end
end
