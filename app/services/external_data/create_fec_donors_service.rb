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

      ApplicationRecord.connection.reconnect!

      ExternalData.fec_donor.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        parallel_in_groups(batch) do |donors|
          donors.each(&:update_fec_donor_data!)
        end
      end

      ApplicationRecord.connection.reconnect!
    end


    def self.parallel_in_groups(batch)
      Parallel.each(batch.in_groups(THREAD_COUNT), in_threads: THREAD_COUNT) do |batch_part|
        ApplicationRecord.connection_pool.with_connection do
          yield batch_part
        end
      end
    end
  end
end
