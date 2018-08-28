# frozen_string_literal: true

class EntityDatatablePresenter < SimpleDelegator
  def to_hash
    {
      'id' => id,
      'name' => name,
      'blurb' => blurb,
      'url' => url,
      'types' => extension_definition_ids
    }
  end

  alias to_h to_hash
end
