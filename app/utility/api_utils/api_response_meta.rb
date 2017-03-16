module ApiUtils
  module ApiResponseMeta
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def meta
        {
          copyright: 'LittleSis CC BY-SA 3.0',
          license: 'https://creativecommons.org/licenses/by-sa/3.0/us/',
          apiVersion: '2.0-beta'
        }
      end
    end
  end
end
