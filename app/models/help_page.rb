class HelpPage < ActiveRecord::Base
  include EditablePage

  has_paper_trail
end
