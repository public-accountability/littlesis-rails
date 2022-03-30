# frozen_string_literal: true

# Adds helper methods for streaming responses
# The including Controller must also include ActionController::Live
module StreamingController
  private

  # Sends ActiveRecord Relation as csv.
  # stream_active_record(Entity.all) will stream all entities to client
  # @param relation [ActiveRecord::Relation]
  # @param include_header [Boolean] include csv header row
  # @param no_buffering [Boolean] tell nginx not to buffer response
  # @param filename [String, Nil] filename to for the attachment
  def stream_active_record_csv(relation, include_header: true, no_buffering: false, filename: nil)
    headers['X-Accel-Buffering'] = 'no' if no_buffering
    filename = "#{relation.table_name}.csv" if filename.nil?

    send_stream(filename: filename, disposition: 'attachment') do |stream|
      stream.write(relation.attribute_names.to_csv) if include_header
      relation.find_each { |record| stream.write(record.to_csv) }
    end
  end
end
