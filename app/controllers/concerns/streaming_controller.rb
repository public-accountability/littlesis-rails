# frozen_string_literal: true

# Adds helper methods for streaming responses
module StreamingController
  private

  # Sends ActiveRecord Relation as csv.
  # stream_active_record(Entity.all) will stream all entities to client
  # @param relation [ActiveRecord::Relation]
  # @param header [Boolean] Include csv header row
  def stream_active_record_csv(relation, header: true)
    stream_response(before: header ? relation.attribute_names.to_csv : nil) do
      relation.find_each.lazy.map(&:to_csv)
    end
  end

  # Streams enumerator to client.
  #
  #   steam_response { Entity.all.find_each }
  #   steam_response(no_buffering: true) { Entity.all.find_each }
  #
  #   stream_response(before: "get ready for some data\n") do
  #     100_000.times.lazy.map { "#{SecureRandom.hex}\n" }
  #    end
  #
  # @param before [String, Nil] additional data to include before iterating
  # @param no_buffering [Boolean] set header to tell nginx not to buffer response
  def stream_response(before: nil, no_buffering: false)
    headers['X-Accel-Buffering'] = 'no' if no_buffering

    self.response_body = Enumerator.new do |lines|
      lines << before if before
      yield.each { |record| lines << record }
    end
  end
end
