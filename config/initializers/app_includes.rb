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
      #logger.info "#{id} - #{match['attrs']['sphincter_index_id']}"
      #(id - match['attrs']['sphincter_index_id']) / Sphincter::Configure.index_count
      id
    end
    
    logger.info ids.join ','

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
  rescue Sphinx::SphinxInternalError  
    #WillPaginate::Collection.new(0,0,0)
    []
  end

end

module Sphincter::Configure

  ##
  # A class for building sphinx.conf source/index sections.

  class Index
    def configure
      conn = @klass.connection
      pk = conn.quote_column_name @klass.primary_key
      index_id = @options[:index_id]

      index_count = Sphincter::Configure.index_count

      @fields << "#{@table}.#{pk} AS #{pk}"
      @fields << "#{index_id} AS sphincter_index_id"
      @fields << "'#{@klass.name}' AS sphincter_klass"

      @options[:fields].each do |field|
        case field
        when /\./ then add_include(*field.split('.', 2))
        else           @fields << add_field(field)
        end
      end

      @fields = @fields.join ', '

      @where << "#{@table}.#{pk} >= $start"
      @where << "#{@table}.#{pk} <= $end"
      @where.push(*@options[:conditions])
      @where = @where.compact.join ' AND '

      query = "SELECT #{@fields} FROM #{@tables} WHERE #{@where}"
      query << " GROUP BY #{@table}.#{pk}" if @group

      @source_conf['sql_query'] = query
      @source_conf['sql_query_info'] =
        "SELECT * FROM #{@table} " \
          "WHERE #{@table}.#{pk} = $id"
      @source_conf['sql_query_range'] =
        "SELECT MIN(#{pk}), MAX(#{pk}) FROM #{@table}"
      @source_conf['strip_html'] = @options[:strip_html] ? 1 : 0

      @source_conf
    end
  end
end
