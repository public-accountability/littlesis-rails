namespace :graph do
  desc "builds adjacency list of complete relationship graph"
  require 'graph'
  include Graph

  task :build_all => [:environment] do |task|
    build Link.all.limit(340000)
  end

end
