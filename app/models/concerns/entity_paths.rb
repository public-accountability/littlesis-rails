require 'active_support/concern'

module EntityPaths
  extend ActiveSupport::Concern

  module ClassMethods
    def name_to_legacy_slug(name)
      parameterize_name(name)
    end

    def parameterize_name(name)
      name.tr(" ", "_").tr("/", "~").tr('+', '_').tr('#', '')
    end

    def legacy_url(primary_ext, id, name, action = nil)
      url = "/" + primary_ext.downcase + "/" + id.to_s + "/" + name_to_legacy_slug(name)
      url += "/" + action if action.present?
      url
    end
  end

  def name_to_legacy_slug
    self.class.name_to_legacy_slug(name)
  end

  def legacy_url(action = nil)
    self.class.legacy_url(primary_ext, id, name, action)
  end

  def full_legacy_url(action = nil)
    "//littlesis.org" + legacy_url(action)
  end
end
