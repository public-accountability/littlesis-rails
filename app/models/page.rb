class Page < ActiveRecord::Base
  include EditablePage

  has_paper_trail
end
