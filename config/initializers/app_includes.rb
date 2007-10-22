require 'sphincter'
require 'memcache'
WhiteListHelper.tags.merge %w(table td th tr tbody span)

module Sphincter::Search
  def search(query, options = {})
    sphinx = Sphinx::Client.new

    @host ||= Sphincter::Configure.get_conf['sphincter']['host']
    @port ||= Sphincter::Configure.get_conf['sphincter']['port']

    sphinx.SetServer @host, @port

    options[:conditions] ||= {}
    options[:conditions].each do |column, values|
      values = sphincter_convert_values Array(values)
      sphinx.SetFilter column.to_s, values
    end

    options[:between] ||= {}
    options[:between].each do |column, between|
      min, max = sphincter_convert_values between

      sphinx.SetFilterRange column.to_s, min, max
    end

    @default_per_page ||= Sphincter::Configure.get_conf['sphincter']['per_page']

    per_page = options[:per_page] || @default_per_page
    page = options[:page].to_i
    page_offset = page > 1 ? page - 1 : 0
    offset = page_offset * per_page

    sphinx.SetLimits offset, per_page

    options[:match_mode] ||= Sphinx::Client::SPH_MATCH_ALL
    sphinx.SetMatchMode options[:match_mode]

    index_name = options[:index] || table_name

    sphinx_result = sphinx.Query query, index_name

    matches = sphinx_result['matches'].sort_by do |id, match|
      -match['index'] # #find reverses, lame!
    end
    ids = matches.map do |id, match|
      (id - match['attrs']['sphincter_index_id']) / Sphincter::Configure.index_count
    end
    
    logger.info ids.join '##'

    results = Results.new

    results.records = find ids, :order => options[:order]
    results.total = sphinx_result['total_found']
    results.per_page = per_page

    collection = WillPaginate::Collection.create(options[:page] || 1, per_page) do |pager|
      # inject the result array into the paginated collection:
      pager.replace(results.records)
      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = results.total # Post.count
      end
    end

    collection
  end

end
