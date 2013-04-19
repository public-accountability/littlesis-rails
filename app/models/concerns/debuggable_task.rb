require 'active_support/concern'

module DebuggableTask
  extend ActiveSupport::Concern

  included do
    attr_accessor :debug
  end
  
  def print_debug(str)
    print str + "\n" if debug
  end
end