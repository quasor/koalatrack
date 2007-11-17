WhiteListHelper.tags.merge %w(table td th tr tbody span)

require 'acts_as_solr'
module ActsAsSolr 
  module ClassMethods 
    def paginate_search(query, options = {}, find_options = {}) 
      options, page, per_page = wp_parse_options!(options) 
      pager = WillPaginate::Collection.new(page, per_page, nil) 
      options.merge!(:offset => pager.offset, :limit => per_page)
      result = find_by_solr(query, options, find_options) 
      returning WillPaginate::Collection.new(page, per_page, result.total) do |pager| 
        pager.replace result.records 
      end 
    end 
  end 
end

