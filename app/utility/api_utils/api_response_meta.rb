module ApiUtils
  module ApiResponseMeta
    META = {
      copyright: 'LittleSis CC BY-SA 3.0',
      license: 'https://creativecommons.org/licenses/by-sa/3.0/us/',
      apiVersion: '2.0-beta'
    }

    def meta
      if @model.is_a? ThinkingSphinx::Search
        META.merge({ :currentPage => @model.current_page, :pageCount => @model.total_pages })
      else
        META
      end
    end
  end
end
