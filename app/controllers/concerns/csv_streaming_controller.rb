# frozen_string_literal: true

# adds helper methods stream_active_record and stream_csv
module CSVStreamingController
  private

  # Sends ActiveRecord Relation as csv
  # stream_active_record(Entity.all) will stream all entities to client as csv
  def stream_active_record(relation)
    stream_csv(before: relation.attribute_names.to_csv) do
      relation.find_each.lazy.map(&:to_csv)
    end
  end

  # steam_csv { Entity.all.find_each }
  # steam_csv(before: Entity.attribute_names) { Entity.all.find_each }
  def stream_csv(before: nil, no_buffering: false)
    headers['X-Accel-Buffering'] = 'no' if no_buffering

    self.response_body = Enumerator.new do |lines|
      lines << before if before
      yield.each { |record| lines << record }
    end
  end
end
