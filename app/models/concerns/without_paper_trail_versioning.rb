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
    paper_trail.disable
    yield
  ensure
    paper_trail.enable
  end
end
