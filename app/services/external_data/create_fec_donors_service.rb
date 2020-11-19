# frozen_string_literal: true

# donor = unique combination of Name + City + State + Zip_code + Employer + Occupation
class ExternalData
  module CreateFECDonorsService
    BATCH_SIZE = 5000
    THREAD_COUNT = 5

    def self.run
      ExternalData.fec_contribution.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        parallel_in_groups(batch) do |contributions|
          contributions.each(&:create_donor_from_self)
        end
      end

      ApplicationRecord.connection.reconnect! unless Rails.env.test?

      ExternalData.fec_donor.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        parallel_in_groups(batch) do |donors|
          donors.each(&:update_fec_donor_data!)
        end
      end

      ApplicationRecord.connection.reconnect! unless Rails.env.test?
    end

    if Rails.env.test?
      def self.parallel_in_groups(batch)
        yield batch
      end
    else
      def self.parallel_in_groups(batch)
        Parallel.each(batch.in_groups(THREAD_COUNT), in_threads: THREAD_COUNT) do |batch_part|
          ApplicationRecord.connection_pool.with_connection do
            yield batch_part.compact
          end
        end
      end
    end
  end
end
