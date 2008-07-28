WhiteListHelper.tags.merge %w(table td th tr tbody span)

require 'acts_as_solr'
module ActsAsSolr 
  module ClassMethods 
    def paginate_search(query, options = {}, find_options = {}) 
      page, per_page, total = wp_parse_options(options) 
      options.delete(:per_page)
      options.delete(:page)
      
      logger.info ("options:#{options.inspect} page:#{page.inspect} per_page:#{per_page.inspect}")
      pager = WillPaginate::Collection.new(page, per_page, nil) 
      options.merge!(:offset => pager.offset, :limit => per_page)
      result = find_by_solr(query, options, find_options) 
      returning WillPaginate::Collection.new(page, per_page, result.total) do |pager| 
        pager.replace result.records 
      end 
    end 
  end 
end

