# example:
# class Alias
#   extend WithoutPaperTrailVersioning
#   [...]
# end
#
# Alias.without_versioning { ...}
#
module WithoutPaperTrailVersioning
  def without_versioning
    PaperTrail.request.disable_model(self)
    yield
  ensure
    PaperTrail.request.enable_model(self)
  end
end
