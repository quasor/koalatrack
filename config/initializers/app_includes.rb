require 'sphincter'
#require 'memcache'
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
    
    logger.info(ids.join(','))

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
  class Index
    ##
    # Adds plain field +field+ to the index from class +klass+ using
    # +as_table+ as the table name.

    def add_field_simple(field)
      field_name, friendly_name = field.split ' AS '
      add_field(field_name, @klass, as_table = nil, friendly_name)
    end

    def add_field(field, klass = @klass, as_table = nil, friendly_name = nil)
      table = klass.table_name
      quoted_field = @conn.quote_column_name field

      column_type = klass.columns_hash[field].type
      expr = case column_type
             when :date, :datetime, :time, :timestamp then
               @source_conf['sql_date_column'] << field
               "UNIX_TIMESTAMP(#{table}.#{quoted_field})"
             when :boolean, :integer then
               @source_conf['sql_group_column'] << field
               "#{table}.#{quoted_field}"
             when :string, :text then
               "#{table}.#{quoted_field}"
             else
               raise Sphincter::Error, "unknown column type #{column_type}"
             end

      ###as_name = [as_table, field].compact.join '_'
      as_name = friendly_name || field
      as_name = @conn.quote_column_name as_name

    "#{expr} AS #{as_name}"
    end

    ##
    # Includes field +as_field+ from association +as_name+ in the index.

    def add_include(as_name, as_field)
      as_field, friendly_name = as_field.split ' AS '
      as_assoc = @klass.reflect_on_all_associations.find do |assoc|
        assoc.name == as_name.intern
      end

      if as_assoc.nil? then
        raise Sphincter::Error,
            "could not find association \"#{as_name}\" in #{@klass.name}"
      end

      as_klass = as_assoc.class_name.constantize
      as_table = as_klass.table_name

      as_klass_key = @conn.quote_column_name as_klass.primary_key.to_s
      as_assoc_key = @conn.quote_column_name as_assoc.primary_key_name.to_s

      case as_assoc.macro
      when :belongs_to then
        @fields << add_field(as_field, as_klass, as_table, friendly_name)
        @tables << " LEFT JOIN #{as_table} ON" \
                   " #{@table}.#{as_assoc_key} = #{as_table}.#{as_klass_key}"

      when :has_many then
        if as_assoc.options.include? :through then
          raise Sphincter::Error,
                "unsupported macro has_many :through for \"#{as_name}\" " \
                "in #{klass.name}.add_index"
        end

        as_pkey = @conn.quote_column_name as_klass.primary_key.to_s
        as_fkey = @conn.quote_column_name as_assoc.primary_key_name.to_s

        ### as_name = [as_table, as_field].compact.join '_'
        as_name = friendly_name ? friendly_name : as_field
        as_name = @conn.quote_column_name as_name

        field = @conn.quote_column_name as_field
        @fields << "GROUP_CONCAT(#{as_table}.#{field} SEPARATOR ' ') AS #{as_name}"

        if as_assoc.options.include? :as then
          poly_name = as_assoc.options[:as]
          id_col = @conn.quote_column_name "#{poly_name}_id"
          type_col = @conn.quote_column_name "#{poly_name}_type"

          @tables << " LEFT JOIN #{as_table} ON"\
                     " #{@table}.#{as_klass_key} = #{as_table}.#{id_col} AND" \
                     " #{@conn.quote @klass.name} = #{as_table}.#{type_col}"
        else
          @tables << " LEFT JOIN #{as_table} ON" \
                     " #{@table}.#{as_klass_key} = #{as_table}.#{as_assoc_key}"
        end

        @group = true
      else
        raise Sphincter::Error,
              "unsupported macro #{as_assoc.macro} for \"#{as_name}\" " \
              "in #{klass.name}.add_index"
      end
    end

  ##
  # A class for building sphinx.conf source/index sections.
    def configure
      conn = @klass.connection
      pk = conn.quote_column_name @klass.primary_key
      index_id = @options[:index_id]

      index_count = Sphincter::Configure.index_count

      @fields << "#{@table}.#{pk} AS #{pk}"
      @fields << "#{index_id} AS sphincter_index_id"
      @fields << "'#{@klass.name}' AS sphincter_klass"

      @options[:fields].each do |field, friendly_name|
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

require 'acts_as_ferret'

module ActsAsFerret 
  module ClassMethods 
    def paginate_search(query, options = {}, find_options = {}) 
      options, page, per_page = wp_parse_options!(options) 
      pager = WillPaginate::Collection.new(page, per_page, nil) 
      options.merge!(:offset => pager.offset, :limit => per_page) 
      result = result = find_by_contents(query, options, find_options) 
      returning WillPaginate::Collection.new(page, per_page, result.total_hits) do |pager| 
        pager.replace result 
      end 
    end 
  end 
end
  