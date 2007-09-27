module SymetrieCom
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)              
      end
      # This module provides an enhanced acts_as_nested_set mixin for ActiveRecord.
      # Please see the README for background information, examples, and tips on usage.
      module ClassMethods
        # Configuration options are:
        # * +dependent+ - behaviour for cascading destroy operations (default: :delete_all)
        # * +parent_column+ - Column name for the parent/child foreign key (default: +parent_id+).
        # * +left_column+ - Column name for the left index (default: +lft+). 
        # * +right_column+ - Column name for the right index (default: +rgt+). NOTE: 
        #   Don't use +left+ and +right+, since these are reserved database words.
        # * +scope+ - Restricts what is to be considered a tree. Given a symbol, it'll attach "_id" 
        #   (if it isn't there already) and use that as the foreign key restriction. It's also possible 
        #   to give it an entire string that is interpolated if you need a tighter scope than just a foreign key.
        #   Example: <tt>acts_as_nested_set :scope => 'tree_id = #{tree_id} AND completed = 0'</tt>
        # * +text_column+ - Column name for the title field (optional). Used as default in the 
        #   {your-class}_options_for_select helper method. If empty, will use the first string field 
        #   of your model class.
        def acts_as_nested_set(options = {})          
          
          options[:scope] = "#{options[:scope]}_id".intern if options[:scope].is_a?(Symbol) && options[:scope].to_s !~ /_id$/
          
          write_inheritable_attribute(:acts_as_nested_set_options,
             { :parent_column  => (options[:parent_column] || 'parent_id'),
               :left_column    => (options[:left_column]   || 'lft'),
               :right_column   => (options[:right_column]  || 'rgt'),
               :scope          => (options[:scope] || '1 = 1'),
               :text_column    => (options[:text_column] || columns.collect{|c| (c.type == :string) ? c.name : nil }.compact.first),
               :class          => self, # for single-table inheritance
               :dependent      => (options[:dependent] || :delete_all) # accepts :delete_all and :destroy
              } )
          
          class_inheritable_reader :acts_as_nested_set_options
          
          if acts_as_nested_set_options[:scope].is_a?(Symbol)
            scope_condition_method = %(
              def scope_condition
                if #{acts_as_nested_set_options[:scope].to_s}.nil?
                  "#{table_name}.#{acts_as_nested_set_options[:scope].to_s} IS NULL"
                else
                  "#{table_name}.#{acts_as_nested_set_options[:scope].to_s} = \#{#{acts_as_nested_set_options[:scope].to_s}}"
                end
              end
            )
          else
            scope_condition_method = "def scope_condition() \"#{acts_as_nested_set_options[:scope]}\" end"
          end
          
          ## add counter cache for fast child counts?
          belongs_to :parent, :class_name => name, :foreign_key => acts_as_nested_set_options[:parent_column]
          has_many :children, :class_name => name, :foreign_key => acts_as_nested_set_options[:parent_column],
            :order => acts_as_nested_set_options[:left_column], :dependent => :nullify # the dependency behavior is actually specified in the options: default is delete_all, you can specify :dependent => :destroy
          
          # skip recursive destroy calls
          attr_accessor  :skip_before_destroy
          
          # no bulk assignment
          attr_protected  acts_as_nested_set_options[:left_column].intern,
                          acts_as_nested_set_options[:right_column].intern
          # no assignment to structure fields
          class_eval <<-EOV
            before_create :set_left_right
            before_save :record_parent
            after_save :move_if_new_parent
            
            include SymetrieCom::Acts::NestedSet::InstanceMethods
          
            def #{acts_as_nested_set_options[:left_column]}=(x)
              raise ActiveRecord::ActiveRecordError, "Unauthorized assignment to #{acts_as_nested_set_options[:left_column]}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
            end
            def #{acts_as_nested_set_options[:right_column]}=(x)
              raise ActiveRecord::ActiveRecordError, "Unauthorized assignment to #{acts_as_nested_set_options[:right_column]}: it's an internal field handled by acts_as_nested_set code, use move_to_* methods instead."
            end
            #{scope_condition_method}
          EOV
        end
        
        # Most query methods are wrapped in with_scope to provide further filtering
        # find_in_nested_set(what, outer_scope, inner_scope)
        # inner scope is user supplied, while outer_scope is the normal query
        # this way the user can override most scope attributes, except :conditions
        # which is merged; use :reverse => true to sort result in reverse direction
        def find_in_nested_set(*args)
          what, outer_scope, inner_scope = case args.length
            when 3 then [args[0], args[1], args[2]]
            when 2 then [args[0], nil, args[1]]
            when 1 then [args[0], nil, nil]
            else [:all, nil, nil]
          end
          if inner_scope && outer_scope && inner_scope.delete(:reverse) && outer_scope[:order] == "#{prefixed_left_col_name}"
            outer_scope[:order] = "#{prefixed_right_col_name} DESC"
          end
          acts_as_nested_set_options[:class].with_scope(:find => (outer_scope || {})) do
            acts_as_nested_set_options[:class].find(what, inner_scope || {})
          end
        end
        
        # Count wrapped in with_scope
        def count_in_nested_set(*args)
          outer_scope, inner_scope = case args.length
            when 2 then [args[0], args[1]]
            when 1 then [nil, args[0]]
            else [nil, nil]
          end
          acts_as_nested_set_options[:class].with_scope(:find => (outer_scope || {})) do
            acts_as_nested_set_options[:class].count(inner_scope || {})
          end
        end
      
        # Loop through set using block
        # pass :nested => false when result is not fully parent-child relational
        # for example with filtered result sets
        def recurse_result_set(result, options = {}, &block)
          return result unless block_given? 
          inner_recursion = options.delete(:inner_recursion)
          result_set = inner_recursion ? result : result.dup
          
          parent_id = (options.delete(:parent_id) || result_set.first[result_set.first.parent_col_name]) rescue nil
          options[:level] ||= 0
          options[:nested] = true unless options.key?(:nested)
                   
          siblings = options[:nested] ? result_set.select { |s| s.parent_id == parent_id } : result_set           
          siblings.each do |sibling|
            result_set.delete(sibling)           
            block.call(sibling, options[:level])
            opts = { :parent_id => sibling.id, :level => options[:level] + 1, :inner_recursion => true }           
            recurse_result_set(result_set, opts, &block) if options[:nested]
          end
          result_set.each { |orphan| block.call(orphan, options[:level]) } unless inner_recursion
        end
       
        # Loop and create a nested array of hashes (with children property)
        # pass :nested => false when result is not fully parent-child relational
        # for example with filtered result sets
        def result_to_array(result, options = {}, &block)
          array = []
          inner_recursion = options.delete(:inner_recursion)
          result_set = inner_recursion ? result : result.dup
          
          parent_id = (options.delete(:parent_id) || result_set.first[result_set.first.parent_col_name]) rescue nil
          level = options[:level] || 0
          children = options.delete(:children) || :children
          options[:nested] = true unless options.key?(:nested)
               
          siblings = options[:nested] ? result_set.select { |s| s.parent_id == parent_id } : result_set
          siblings.each do |sibling|
            result_set.delete(sibling)
            node = block_given? ? block.call(sibling, level) : sibling.attributes           
            if options[:nested]              
              opts = { :parent_id => sibling.id, :level => level + 1, :children => children, :inner_recursion => true }
              childnodes = result_to_array(result_set, opts, &block)
              node[ children ] = childnodes if !childnodes.empty? && node.respond_to?(:[]=)
            end
            array << node
          end
          result_set.each { |orphan| array << (block_given? ? block.call(orphan, level) : orphan.attributes) } unless inner_recursion         
          array
        end
        
        # Loop and create an xml structure. The following options are available
        # :root sets the root tag, :children sets the siblings tag
        # :record sets the node item tag, if given
        # see also: result_to_array and ActiveRecord::XmlSerialization
        def result_to_xml(result, options = {}, &block)
          inner_recursion = options.delete(:inner_recursion)         
          result_set = inner_recursion ? result : result.dup
          
          parent_id = (options.delete(:parent_id) || result_set.first[result_set.first.parent_col_name]) rescue nil
          options[:nested] = true unless options.key?(:nested)
          
          options[:except] ||= []
          [:left_column, :right_column, :parent_column].each do |opt|
            column = acts_as_nested_set_options[opt].intern
            options[:except] << column unless options[:except].include?(column)
          end
          
          options[:indent]  ||= 2
          options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
          options[:builder].instruct! unless options.delete(:skip_instruct)
                    
          record = options.delete(:record)
          root = options.delete(:root) || :nodes
          children = options.delete(:children) || :children
          
          attrs = {}
          attrs[:xmlns] = options[:namespace] if options[:namespace] 
          
          siblings = options[:nested] ? result_set.select { |s| s.parent_id == parent_id } : result_set       
          options[:builder].tag!(root, attrs) do
            siblings.each do |sibling|
              result_set.delete(sibling) if options[:nested]         
              proc = Proc.new do |options| 
                proc_opts = options.merge(:parent_id => sibling.id, :root => children, :record => record, :inner_recursion => true)  
                sibling.class.result_to_xml(result_set, proc_opts, &block)
              end 
              procs = []
              procs << Proc.new { |options| block.call(options, sibling) } if block_given?   
              procs << proc if options[:nested]       
              opts = options.merge(:procs => procs, :skip_instruct => true, :root => record)             
              sibling.to_xml(opts)
            end
          end
          options[:builder].target!
        end
                 
        # Returns the single root for the class (or just the first root, if there are several).
        # Deprecation note: the original acts_as_nested_set allowed roots to have parent_id = 0,
        # so we currently do the same. This silliness will not be tolerated in future versions, however.
        def root(scope = {})
          find_in_nested_set(:first, { :conditions => "(#{prefixed_parent_col_name} IS NULL OR #{prefixed_parent_col_name} = 0)" }, scope)
        end
        
        # Returns the roots and/or virtual roots of all trees. See the explanation of virtual roots in the README.
        def roots(scope = {})
          find_in_nested_set(:all, { :conditions => "(#{prefixed_parent_col_name} IS NULL OR #{prefixed_parent_col_name} = 0)", :order => "#{prefixed_left_col_name}" }, scope)
        end
        
        # Checks the left/right indexes of all records, 
        # returning the number of records checked. Throws ActiveRecord::ActiveRecordError if it finds a problem.
        def check_all
          total = 0
          transaction do
            # if there are virtual roots, only call check_full_tree on the first, because it will check other virtual roots in that tree.
            total = roots.inject(0) {|sum, r| sum + (r[r.left_col_name] == 1 ? r.check_full_tree : 0 )}
            raise ActiveRecord::ActiveRecordError, "Scope problems or nodes without a valid root" unless acts_as_nested_set_options[:class].count == total
          end
          return total
        end
        
        # Re-calculate the left/right values of all nodes. Can be used to convert ordinary trees into nested sets.
        def renumber_all
          scopes = []
          # only call it once for each scope_condition (if the scope conditions are messed up, this will obviously cause problems)
          roots.each do |r|
            r.renumber_full_tree unless scopes.include?(r.scope_condition)
            scopes << r.scope_condition
          end
        end
        
        # Returns an SQL fragment that matches _items_ *and* all of their descendants, for use in a WHERE clause.
        # You can pass it a single object, a single ID, or an array of objects and/or IDs.
        #   # if a.lft = 2, a.rgt = 7, b.lft = 12 and b.rgt = 13
        #   Set.sql_for([a,b]) # returns "((lft BETWEEN 2 AND 7) OR (lft BETWEEN 12 AND 13))"
        # Returns "1 != 1" if passed no items. If you need to exclude items, just use "NOT (#{sql_for(items)})".
        # Note that if you have multiple trees, it is up to you to apply your scope condition.
        def sql_for(items)
          items = [items] unless items.is_a?(Array)
          # get objects for IDs
          items.collect! {|s| s.is_a?(acts_as_nested_set_options[:class]) ? s : acts_as_nested_set_options[:class].find(s)}.uniq
          items.reject! {|e| e.new_record?} # exclude unsaved items, since they don't have left/right values yet
          
          return "1 != 1" if items.empty? # PostgreSQL didn't like '0', and SQLite3 didn't like 'FALSE'
          items.map! {|e| "(#{prefixed_left_col_name} BETWEEN #{e[left_col_name]} AND #{e[right_col_name]})" }
          "(#{items.join(' OR ')})"
        end
        
        def left_col_name#:nodoc:
          acts_as_nested_set_options[:left_column]
        end
        def prefixed_left_col_name#:nodoc:
          "#{table_name}.#{left_col_name}"
        end        
        def right_col_name#:nodoc:
          acts_as_nested_set_options[:right_column]
        end
        def prefixed_right_col_name#:nodoc:
          "#{table_name}.#{right_col_name}"
        end
        def parent_col_name#:nodoc:
          acts_as_nested_set_options[:parent_column]
        end
        def prefixed_parent_col_name#:nodoc:
          "#{table_name}.#{parent_col_name}"
        end
        def base_set_class#:nodoc:
          acts_as_nested_set_options[:class] # for single-table inheritance
        end
               
      end

      # This module provides instance methods for an enhanced acts_as_nested_set mixin. Please see the README for background information, examples, and tips on usage.
      module InstanceMethods
        # convenience methods to make the code more readable
        def left_col_name#:nodoc:
          self.class.left_col_name
        end
        def prefixed_left_col_name#:nodoc:
          self.class.prefixed_left_col_name
        end        
        def right_col_name#:nodoc:
         self.class.right_col_name
        end
        def prefixed_right_col_name#:nodoc:
          self.class.prefixed_right_col_name
        end
        def parent_col_name#:nodoc:
          self.class.parent_col_name
        end
        def prefixed_parent_col_name#:nodoc:
          self.class.prefixed_parent_col_name
        end
        def base_set_class#:nodoc:
          acts_as_nested_set_options[:class] # for single-table inheritance
        end
        
        ## mark all these as #:nodoc: ?
        
        # On creation, automatically add the new node to the right of all existing nodes in this tree.
        def set_left_right # already protected by a transaction within #create
          maxright = base_set_class.maximum(right_col_name, :conditions => scope_condition) || 0
          self[left_col_name] = maxright+1
          self[right_col_name] = maxright+2
        end
        
        # record the parent before save
        def record_parent # already protected by a transaction within #save
          if new_record?
            @old_parent = nil
          else
            @old_parent = base_set_class.find(self[self.class.primary_key])[parent_col_name]
          end
        end
        
        # if the save changed the parent, update the lft/rgt values 
        def move_if_new_parent # already protected by a transaction within #save  
          if @old_parent != self[parent_col_name]
            if self[parent_col_name] == nil
              self.move_to_root
            else
              self.move_to_child_of(self[parent_col_name])
            end
          end
        end 
        
        # Override the destroy method because AR wants to run its own callbacks (deleting children) prior to calling before_destroy,
        # but we can handle the destruction of children more efficiently
      	def destroy
      		before_before_destroy
      		super
      	end
      	
        # On destruction, delete all children and shift the lft/rgt values back to the left so the counts still work.
        def before_before_destroy # already protected by a transaction within #destroy
          return if self[right_col_name].nil? || self[left_col_name].nil? || self.skip_before_destroy
          self.reload # in case a concurrent move has altered the indexes
          dif = self[right_col_name] - self[left_col_name] + 1
          if acts_as_nested_set_options[:dependent] == :destroy
            set = base_set_class.find(:all, :conditions => "#{scope_condition} AND (#{prefixed_left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]})", :order => "#{prefixed_right_col_name} DESC")     
            set.each { |child| child.skip_before_destroy = true; child.destroy }
          else
            ## this is equivalent to :dependent => :delete_all
            base_set_class.delete_all( "#{scope_condition} AND (#{prefixed_left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]})" )
          end
          base_set_class.update_all("#{left_col_name} = CASE \
                                      WHEN #{left_col_name} > #{self[right_col_name]} THEN (#{left_col_name} - #{dif}) \
                                      ELSE #{left_col_name} END, \
                                 #{right_col_name} = CASE \
                                      WHEN #{right_col_name} > #{self[right_col_name]} THEN (#{right_col_name} - #{dif} ) \
                                      ELSE #{right_col_name} END",
                                 scope_condition)
        end
        
        # By default, records are compared and sorted using the left column.
        def <=>(x)
          self[left_col_name] <=> x[left_col_name]
        end
                
        # Returns this record's root ancestor.
        def root(scope = {})
          # the BETWEEN clause is needed to ensure we get the right virtual root, if using those
          self.class.find_in_nested_set(:first, { :conditions => "#{scope_condition} \
            AND (#{prefixed_parent_col_name} IS NULL OR #{prefixed_parent_col_name} = 0) AND (#{self[left_col_name]} BETWEEN #{prefixed_left_col_name} AND #{prefixed_right_col_name})" }, scope)
        end
        
        # Returns the root or virtual roots of this record's tree (a tree cannot have more than one real root). See the explanation of virtual roots in the README.
        def roots(scope = {})
          self.class.find_in_nested_set(:all, { :conditions => "#{scope_condition} AND (#{prefixed_parent_col_name} IS NULL OR #{prefixed_parent_col_name} = 0)", :order => "#{prefixed_left_col_name}" }, scope)
        end

## use association finder sql??
       # # Returns this record's parent.
       # def parent
       #   self.class.find_in_nested_set(self[parent_col_name]) if self[parent_col_name]
       # end
        
        # Returns an array of all parents, starting with the root.
        def ancestors(scope = {})
          self_and_ancestors(scope) - [self]
        end
        
        # Returns an array of all parents plus self, starting with the root.
        def self_and_ancestors(scope = {})
          self.class.find_in_nested_set(:all, { :conditions => "#{scope_condition} AND (#{self[left_col_name]} BETWEEN #{prefixed_left_col_name} AND #{prefixed_right_col_name})", :order => "#{prefixed_left_col_name}" }, scope)
        end
        
        # Returns all the children of this node's parent, except self.
        def siblings(scope = {})
          self_and_siblings(scope) - [self]
        end
        
        # Returns all siblings to the left of self, in descending order, so the first sibling is the one closest to the left of self
        def previous_siblings(scope = {})
          self.class.find_in_nested_set(:all, 
            { :conditions => ["#{scope_condition} AND #{prefixed_parent_col_name} = #{self[parent_col_name]} AND #{self.class.table_name}.id != ? AND #{prefixed_right_col_name} < ?", self.id, self[left_col_name]], :order => "#{prefixed_left_col_name} DESC" }, scope)
        end
               
        # Returns all siblings to the right of self, in ascending order, so the first sibling is the one closest to the right of self
        def next_siblings(scope = {})
          self.class.find_in_nested_set(:all, 
            { :conditions => ["#{scope_condition} AND #{prefixed_parent_col_name} = #{self[parent_col_name]} AND #{self.class.table_name}.id != ? AND #{prefixed_left_col_name} > ?", self.id, self[right_col_name]], :order => "#{prefixed_left_col_name} ASC"}, scope)
        end
        
        # Returns first siblings amongst it's siblings.
        def first_sibling(scope = {})
          self_and_siblings(scope.merge(:limit => 1, :order => "#{prefixed_left_col_name} ASC")).first
        end
        
        def first_sibling?(scope = {})
          self == first_sibling(scope)
        end
        alias :first? :first_sibling?
        
        # Returns last siblings amongst it's siblings.
        def last_sibling(scope = {})
          self_and_siblings(scope.merge(:limit => 1, :order => "#{prefixed_left_col_name} DESC")).first
        end
        
        def last_sibling?(scope = {})
          self == last_sibling(scope)
        end
        alias :last? :last_sibling?
                                      
        # Returns previous sibling of node or nil if there is none.
        def previous_sibling(num = 1, scope = {})
          scope[:limit] = num
          siblings = previous_siblings(scope)
          num == 1 ? siblings.first : siblings
        end        
        alias :higher_item :previous_sibling
        
        # Returns next sibling of node or nil if there is none.
        def next_sibling(num = 1, scope = {})
          scope[:limit] = num
          siblings = next_siblings(scope)
          num == 1 ? siblings.first : siblings
        end
        alias :lower_item :next_sibling
        
        # Returns all the children of this node's parent, including self.
        def self_and_siblings(scope = {})
          if self[parent_col_name].nil? || self[parent_col_name].zero?
            [self]
          else
            self.class.find_in_nested_set(:all, { :conditions => "#{scope_condition} AND #{prefixed_parent_col_name} = #{self[parent_col_name]}", :order => "#{prefixed_left_col_name}" }, scope)
          end
        end
        
        # Returns the level of this object in the tree, root level being 0.
        def level(scope = {})
          return 0 if self[parent_col_name].nil?
          self.class.count_in_nested_set({ :conditions => "#{scope_condition} AND (#{self[left_col_name]} BETWEEN #{prefixed_left_col_name} AND #{prefixed_right_col_name})" }, scope) - 1
        end
        
        # Returns the number of nested children of this object.
        def all_children_count(scope = nil)
          return all_children(scope).length if scope.is_a?(Hash)
          return (self[right_col_name] - self[left_col_name] - 1)/2
        end
        
        # Returns itself and all nested children.
        # Pass :exclude => item, or id, or [items or id] to exclude one or more items *and* all of their descendants.
        def full_set(scope = {})
          if exclude = scope.delete(:exclude)
            exclude_str = " AND NOT (#{base_set_class.sql_for(exclude)}) "
          elsif new_record? || self[right_col_name] - self[left_col_name] == 1
            return [self]
          end
          self.class.find_in_nested_set(:all,  
            { :conditions => "#{scope_condition} #{exclude_str} AND (#{prefixed_left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]})", :order => "#{prefixed_left_col_name}" }, scope)
        end
        
        # Returns all children and nested children.
        # Pass :exclude => item, or id, or [items or id] to exclude one or more items *and* all of their descendants.
        def all_children(scope = {})
          full_set(scope) - [self]
        end


#### # Returns this record's immediate children.
#### def children(scope = {})
####   self.class.find_in_nested_set(:all, { :conditions => "#{scope_condition} AND #{prefixed_parent_col_name} = #{self.id}", :order => "#{prefixed_left_col_name}" }, scope)
#### end
#### 

## perhaps we should leave this?
#### # Deprecated
#### alias direct_children children

        # Returns this record's terminal children (nodes without children).
        def leaves(scope = {})
          self.class.find_in_nested_set(:all, 
            { :conditions => "#{scope_condition} AND (#{prefixed_left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]}) AND #{prefixed_left_col_name} + 1 = #{prefixed_right_col_name}", :order => "#{prefixed_left_col_name}" }, scope)
        end
        
        # Returns the count of this record's terminal children (nodes without children).
        def leaves_count(scope = {})
          self.class.count_in_nested_set({ :conditions => "#{scope_condition} AND (#{prefixed_left_col_name} BETWEEN #{self[left_col_name]} AND #{self[right_col_name]}) AND #{prefixed_left_col_name} + 1 = #{prefixed_right_col_name}" }, scope)
        end
        
        # Checks the left/right indexes of one node and all descendants. 
        # Throws ActiveRecord::ActiveRecordError if it finds a problem.
        def check_subtree
          transaction do
            self.reload
            check # this method is implemented via #check, so that we don't generate lots of unnecessary nested transactions
          end
        end
        
        # Checks the left/right indexes of the entire tree that this node belongs to, 
        # returning the number of records checked. Throws ActiveRecord::ActiveRecordError if it finds a problem.
        # This method is needed because check_subtree alone cannot find gaps between virtual roots, orphaned nodes or endless loops.
        def check_full_tree
          total_nodes = 0
          transaction do
            # virtual roots make this method more complex than it otherwise would be
            n = 1
            roots.each do |r| 
              raise ActiveRecord::ActiveRecordError, "Gaps between roots in the tree containing record ##{r.id}" if r[left_col_name] != n
              r.check_subtree
              n = r[right_col_name] + 1
            end
            total_nodes = roots.inject(0) {|sum, r| sum + r.all_children_count + 1 }
            unless base_set_class.count(:conditions => "#{scope_condition}") == total_nodes
              raise ActiveRecord::ActiveRecordError, "Orphaned nodes or endless loops in the tree containing record ##{self.id}"
            end
          end
          return total_nodes
        end
        
        # Re-calculate the left/right values of all nodes in this record's tree. Can be used to convert an ordinary tree into a nested set.
        def renumber_full_tree
          indexes = []
          n = 1
          transaction do
            for r in roots # because we may have virtual roots
              n = r.calc_numbers(n, indexes)
            end
            for i in indexes
              base_set_class.update_all("#{left_col_name} = #{i[:lft]}, #{right_col_name} = #{i[:rgt]}", "#{self.class.primary_key} = #{i[:id]}")
            end
          end
          ## reload?
        end
                
        # Move this node to the left of _target_ (you can pass an object or just an id).
        # Unsaved changes in either object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_left_of(target)
          self.move_to target, :left
        end
        
        # Move this node to the right of _target_ (you can pass an object or just an id).
        # Unsaved changes in either object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_right_of(target)
          self.move_to target, :right
        end
        
        # Make this node a child of _target_ (you can pass an object or just an id).
        # Unsaved changes in either object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_child_of(target)
          self.move_to target, :child
        end
        
        # Move this node to be a root node, to the right of any existing root(s).
        # Unsaved changes in the object will be lost. Raises ActiveRecord::ActiveRecordError if it encounters a problem.
        def move_to_root
          self.move_to_right_of((roots - [self]).last) # need to exclude this object
        end
        
        # Moves a node one up amongst its siblings. Does nothing if it's already
        # the first sibling.
        def move_lower
          next_sib = next_sibling
          move_to_right_of(next_sib) if next_sib
        end

        # Moves a node one down amongst its siblings. Does nothing if it's already
        # the last sibling.
        def move_higher         
          prev_sib = previous_sibling
          move_to_left_of(prev_sib) if prev_sib
        end
        
        # Moves a node one to be the first amongst its siblings. Does nothing if it's already
        # the first sibling.
        def move_to_top
          first_sib = first_sibling
          move_to_left_of(first_sib) if first_sib && self != first_sib
        end
        
        # Moves a node one to be the last amongst its siblings. Does nothing if it's already
        # the last sibling.
        def move_to_bottom
          last_sib = last_sibling
          move_to_right_of(last_sib) if last_sib && self != last_sib
        end
        
        # Swaps the position of two sibling nodes preserving a sibling's descendants.
        # The current implementation only works amongst siblings. Eventually #swap
        # should use #move_to(target, :swap) for better integration.
        def swap(target)
          transaction do
            return false unless self.siblings.include?(target)
            self.reload # the lft/rgt values could be stale (target is reloaded below)
            if target.is_a?(base_set_class)
              target.reload # could be stale
            else
              target = self.class.find_in_nested_set(target) # load object if we were given an ID
            end
            
            direction = (self[left_col_name] < target[left_col_name]) ? :down : :up
          
            i0 = (direction == :up) ? target[left_col_name] : self[left_col_name]
            i1 = (direction == :up) ? target[right_col_name] : self[right_col_name]
            i2 = (direction == :up) ? self[left_col_name] : target[left_col_name]
            i3 = (direction == :up) ? self[right_col_name] : target[right_col_name]
     
            base_set_class.update_all(%[
            #{left_col_name} = CASE WHEN #{left_col_name} BETWEEN #{i0} AND #{i1} THEN #{i3} + #{left_col_name} - #{i1}
              WHEN #{left_col_name} BETWEEN #{i2} AND #{i3} THEN #{i0} + #{left_col_name} - #{i2}
              ELSE #{i0} + #{i3} + #{left_col_name} - #{i1} - #{i2} END,
              #{right_col_name} = CASE WHEN #{right_col_name} BETWEEN #{i0} AND #{i1} THEN #{i3} + #{right_col_name} - #{i1}
              WHEN #{right_col_name} BETWEEN #{i2} AND #{i3} THEN #{i0} + #{right_col_name} - #{i2}
              ELSE #{i0} + #{i3} + #{right_col_name} - #{i1} - #{i2} END ], "#{left_col_name} BETWEEN #{i0} AND #{i3} AND #{i0} < #{i1} AND #{i1} < #{i2} AND #{i2} < #{i3} AND #{scope_condition}")         
            self.reload; target.reload
          end        
        end
        
        protected
        def move_to(target, position) #:nodoc:
          raise ActiveRecord::ActiveRecordError, "You cannot move a new node" if new_record?
          raise ActiveRecord::ActiveRecordError, "You cannot move a node if left or right is nil" unless self[left_col_name] && self[right_col_name]
          
          transaction do
            self.reload # the lft/rgt values could be stale (target is reloaded below)
            if target.is_a?(base_set_class)
              target.reload # could be stale
            else
              target = self.class.find_in_nested_set(target) # load object if we were given an ID
            end
            
            if (target[left_col_name] >= self[left_col_name]) && (target[right_col_name] <= self[right_col_name])
              raise ActiveRecord::ActiveRecordError, "Impossible move, target node cannot be inside moved tree."
            end
            
            # prevent moves between different trees
            if target.scope_condition != scope_condition
              raise ActiveRecord::ActiveRecordError, "Scope conditions do not match. Is the target in the same tree?"
            end
            
            # the move: we just need to define two adjoining segments of the left/right index and swap their positions
            bound = case position
              when :child then target[right_col_name]
              when :left  then target[left_col_name]
              when :right then target[right_col_name] + 1
              else raise ActiveRecord::ActiveRecordError, "Position should be :child, :left or :right ('#{position}' received)."
            end
            
            if bound > self[right_col_name]
              bound = bound - 1
              other_bound = self[right_col_name] + 1
            else
              other_bound = self[left_col_name] - 1
            end
            
            return if bound == self[right_col_name] || bound == self[left_col_name] # there would be no change, and other_bound is now wrong anyway
            
            # we have defined the boundaries of two non-overlapping intervals, 
            # so sorting puts both the intervals and their boundaries in order
            a, b, c, d = [self[left_col_name], self[right_col_name], bound, other_bound].sort
            
            # change nil to NULL for new parent
            if position == :child
              new_parent = target.id
            else
              new_parent = target[parent_col_name].nil? ? 'NULL' : target[parent_col_name]
            end
            
            base_set_class.update_all("\
              #{left_col_name} = CASE \
                WHEN #{left_col_name} BETWEEN #{a} AND #{b} THEN #{left_col_name} + #{d - b} \
                WHEN #{left_col_name} BETWEEN #{c} AND #{d} THEN #{left_col_name} + #{a - c} \
                ELSE #{left_col_name} END, \
              #{right_col_name} = CASE \
                WHEN #{right_col_name} BETWEEN #{a} AND #{b} THEN #{right_col_name} + #{d - b} \
                WHEN #{right_col_name} BETWEEN #{c} AND #{d} THEN #{right_col_name} + #{a - c} \
                ELSE #{right_col_name} END, \
              #{parent_col_name} = CASE \
                WHEN #{self.class.primary_key} = #{self.id} THEN #{new_parent} \
                ELSE #{parent_col_name} END",
              scope_condition)
            self.reload
            target.reload
          end
        end
        
        def check #:nodoc:
          # performance improvements (3X or more for tables with lots of columns) by using :select to load just id, lft and rgt
          ## i don't use the scope condition here, because it shouldn't be needed
          my_children = self.class.find_in_nested_set(:all, :conditions => "#{prefixed_parent_col_name} = #{self.id}",
            :order => "#{prefixed_left_col_name}", :select => "#{self.class.primary_key}, #{prefixed_left_col_name}, #{prefixed_right_col_name}")
          
          if my_children.empty?
            unless self[left_col_name] && self[right_col_name]
              raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{self.id}.#{right_col_name} or #{left_col_name} is blank"
            end
            unless self[right_col_name] - self[left_col_name] == 1
              raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{self.id}.#{right_col_name} should be 1 greater than #{left_col_name}"
            end
          else
            n = self[left_col_name]
            for c in (my_children) # the children come back ordered by lft
              unless c[left_col_name] && c[right_col_name]
                raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{c.id}.#{right_col_name} or #{left_col_name} is blank"
              end
              unless c[left_col_name] == n + 1
                raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{c.id}.#{left_col_name} should be 1 greater than #{n}"
              end
              c.check
              n = c[right_col_name]
            end
            unless self[right_col_name] == n + 1
              raise ActiveRecord::ActiveRecordError, "#{self.class.name}##{self.id}.#{right_col_name} should be 1 greater than #{n}"
            end
          end
        end
        
        # used by the renumbering methods
        def calc_numbers(n, indexes) #:nodoc:
          my_lft = n
          # performance improvements (3X or more for tables with lots of columns) by using :select to load just id, lft and rgt
          ## i don't use the scope condition here, because it shouldn't be needed
          my_children = self.class.find_in_nested_set(:all, :conditions => "#{prefixed_parent_col_name} = #{self.id}",
            :order => "#{prefixed_left_col_name}", :select => "#{self.class.primary_key}, #{prefixed_left_col_name}, #{prefixed_right_col_name}")
          if my_children.empty?
            my_rgt = (n += 1)
          else
            for c in (my_children)
              n = c.calc_numbers(n + 1, indexes)
            end
            my_rgt = (n += 1)
          end
          indexes << {:id => self.id, :lft => my_lft, :rgt => my_rgt} unless self[left_col_name] == my_lft && self[right_col_name] == my_rgt
          return n
        end
        
        # The following code is my crude method of making things concurrency-safe.
        # Basically, we need to ensure that whenever a record is saved, the lft/rgt
        # values are _not_ written to the database, because if any changes to the tree
        # structure occurrred since the object was loaded, the lft/rgt values could 
        # be out of date and corrupt the indexes. 
        # There is an open ticket for this in the Rails Core: http://dev.rubyonrails.org/ticket/6896 
        
        private
          # override the sql preparation method to exclude the lft/rgt columns
          # under the same conditions that the primary key column is excluded
          def attributes_with_quotes(include_primary_key = true) #:nodoc:
            attributes.inject({}) do |quoted, (name, value)|
              if column = column_for_attribute(name)
                quoted[name] = quote_value(value, column) unless !include_primary_key && (column.primary || [acts_as_nested_set_options[:left_column], acts_as_nested_set_options[:right_column]].include?(column.name))
              end
              quoted
            end
          end

          # i couldn't figure out how to call attributes_with_quotes without cutting and pasting this private method in.  :(
          # Quote strings appropriately for SQL statements.
          def quote_value(value, column = nil) #:nodoc:
            self.class.connection.quote(value, column)
          end

      end
    end
  end
end


