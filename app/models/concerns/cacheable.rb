module Cacheable
	extend ActiveSupport::Concern

	included do 
	end

	def cache_key(subkey=nil, use_timestamp=false, params=nil)
	  if new_record?
	    key = "#{self.class.model_name.cache_key}/new#{subkey}"
	  else
	  	if use_timestamp && (timestamp = max_updated_column_timestamp)
	  		timestamp = timestamp.utc.to_s(cache_timestamp_format)
		  	id = "#{id}-#{timestamp}"
		  else
		  	id = self.id
		  end

			key = "#{self.class.model_name.cache_key}/#{id}/#{subkey}"
	  end

	  key += "/#{params_to_key(params)}" if params.present?
	  key
	end

	def expire_cache(subkey=nil, use_timestamp=false)
		Rails.cache.delete(cache_key(subkey, use_timestamp))
	end

	def clear_cache
		if new_record?
			pattern = "*#{self.class.model_name.cache_key}/new[\\/\\-]*"
		else
			pattern = "*#{self.class.model_name.cache_key}/#{self.id}[\\/\\-]*"
		end

		Rails.cache.delete_matched(pattern)
	end

	def params_to_key(params)
		params = Hash[params.sort]
		params.to_a.flatten.join("/")
	end
end