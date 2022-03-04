# frozen_string_literal: true

require 'memory_profiler'

# Helps find and debug memory leaks & issues
# Add to ApplicationController
#
#     class ApplicationController < ActionController::Base
#        include MemoryLogger
#        after_action :log_memory
#        around_action :report_memory
#
module MemoryLogger
  @@memory_usage = 0

  private

  def report_memory(&action)
    report = MemoryProfiler.report(top: 500, ignore_files: /memory_profiler/, &action)
    report.pretty_print(scale_bytes: true,
                        to_file: Rails.root.join('tmp', "memory_report.#{Time.current.to_i}.txt"))
  end

  def log_memory
    memory_usage = `ps -o rss= -p #{Process.pid}`.to_i
    memory_diff = memory_usage - @@memory_usage
    @@memory_usage = memory_usage
    Rails.logger.info "Memory usage: #{ActiveSupport::NumberHelper.number_to_human_size(memory_usage)}"
    Rails.logger.info "Memory change: #{memory_diff}"
  end
end
