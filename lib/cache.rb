module Cache
	def self.key_with_params(key, params)
		return key if params.blank?
		key + "/" + params_to_key(params)
	end

	def self.params_to_key(params)
		params = Hash[params.sort]
		params.to_a.flatten.join("/")
	end	
end