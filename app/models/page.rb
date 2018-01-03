class Page < ApplicationRecord
  include EditablePage

  has_paper_trail
end
