# frozen_string_literal: true

class HelpPagesController < EditablePagesController
  namespace 'help'
  page_model HelpPage
end
