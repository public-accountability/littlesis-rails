# frozen_string_literal: true

class ToolkitController < EditablePagesController
  layout 'toolkit'

  namespace 'toolkit'
  page_model ToolkitPage

  before_action -> { set_cache_control(1.day) }, only: [:display, :index]
end
