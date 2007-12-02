class PlaylistsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  rescue_from ActiveRecord::RecordNotFound do
    flash[:warning] = "You do not have permission to #{action_name} that item."      
    if @playlist
      redirect_to @playlist 
    else
      redirect_to playlists_path
    end
  end
  
  # GET /playlists
  # GET /playlists.xml
  def index
    if params[:q] && !params[:q].blank?
      @playlists = Playlist.paginate_search(params[:q], {:per_page => 50, :page => params[:page]} )
      unless @playlists.empty?      
        @summary =  TestCaseExecution.find_by_sql "SELECT last_result as result, count(last_result) as total FROM playlist_test_cases JOIN playlists ON playlist_test_cases.playlist_id = playlists.id WHERE (`playlists`.`id` IN (#{@playlists.collect(&:id).join ','})) GROUP BY last_result"
        @bugs =  TestCaseExecution.find_by_sql "SELECT bug_id FROM test_case_executions JOIN playlist_test_cases ON playlist_test_cases.id = test_case_executions.playlist_test_case_id JOIN playlists ON playlist_test_cases.playlist_id = playlists.id WHERE (`playlists`.`id` IN (#{@playlists.collect(&:id).join ','})  AND bug_id != '')"
      end
      @my_playlists =  []
    elsif logged_in?
      @my_playlists = Playlist.find_all_by_user_id(current_user.id) 
      @playlists = current_user.group.playlists.find(:all, :conditions => ["user_id != ?", current_user.id])
    else
      @playlists = Playlist.find(:all)
      @my_playlists =  []
    end
        
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @playlists }
    end
  end

  # GET /playlists/1
  # GET /playlists/1.xml
  require 'memcache_util'
  def show
    if Cache.get('SummaryUpdater').nil? && params[:show_report]
      Cache.put 'SummaryUpdater', true, 1
      ExecutionSummary.build_summary      
      @refresh = true
    end
    
    @playlist = Playlist.find(params[:id])
    if params[:notrun]
       session[:filtering] = true
    end
    if params[:show_all]
      session[:filtering] = false
    end

    @summary =  TestCaseExecution.find_by_sql "SELECT last_result as result, count(last_result) as total FROM playlist_test_cases JOIN playlists ON playlist_test_cases.playlist_id = playlists.id WHERE (`playlists`.`id` = #{@playlist.id}) GROUP BY last_result"
    @bugs =  TestCaseExecution.find_by_sql "SELECT bug_id FROM test_case_executions JOIN playlist_test_cases ON playlist_test_cases.id = test_case_executions.playlist_test_case_id JOIN playlists ON playlist_test_cases.playlist_id = playlists.id WHERE (`playlists`.`id` = #{@playlist.id})"

    
    sort = case params[:sort]
               when "feature"  then "test_cases.priority_in_feature"
               when "product"  then "test_cases.priority_in_product"
               when "title"   then "title"
               when "assigned" then "users.login"
               when "results" then "last_result"
               when "category" then "categories.ancestor_cache, categories.id"
               else
                 "playlist_test_cases.position"
               end
    sort += " DESC" if params[:desc] == "true"
    @conditions = "test_cases.active = 1"
    @conditions += " AND test_case_executions.updated_at IS NULL" if session[:filtering] 
 
    respond_to do |format|
      format.html do # show.html.erb
        if params[:q] && !params[:q].blank?
          @playlist_test_cases = PlaylistTestCase.paginate_search(params[:q]+" AND playlistid:#{@playlist.id}", {:page => params[:page], :per_page => 25}, {:include => [:test_case], :conditions => {:playlist_id => @playlist.id, 'test_cases.active' => true}})      
        else              
          @playlist_test_cases = @playlist.playlist_test_cases.paginate :page => params[:page], :per_page => 25, :include => [:test_case_executions,{:test_case => :category},:user], :order => sort, :conditions => @conditions  
        end
      end
      format.doc do
        @playlist_test_cases = @playlist.playlist_test_cases.find :all, :include => [{:test_case => :category},:test_case_executions,:user], :order => sort, :conditions => @conditions          
        render :layout => true
      end
      format.xml  { render :xml => @playlist }
    end
  end

  # GET /playlists/new
  # GET /playlists/new.xml
  def new
    @playlist_copy = Playlist.find(params[:id]) if params[:id]
    if @playlist_copy
      @playlist = Playlist.new(:title => "Copy of #{@playlist_copy.title}") 
    else
      @playlist = Playlist.new 
    end
    
    @playlist.user_id = current_user.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @playlist }
    end
  end

  # GET /playlists/1/edit
  def edit
    @playlist = Playlist.find(params[:id])
  end

  # POST /playlists
  # POST /playlists.xml
  def create
    @playlist = Playlist.new(params[:playlist])

    respond_to do |format|
      if @playlist.save
        if !params[:clone_id].blank?
          @playlist_test_cases = Playlist.find(params[:clone_id]).playlist_test_cases.collect(&:clone)
          @playlist_test_cases.collect {|p| p.test_case_executions_count = p.last_result = 0 }
          @playlist.playlist_test_cases << @playlist_test_cases
        end
        flash[:notice] = 'Playlist was successfully created.'
        format.html { redirect_to(@playlist) }
        format.xml  { render :xml => @playlist, :status => :created, :location => @playlist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /playlists/1
  # PUT /playlists/1.xml
  def update
    @playlist = Playlist.find(params[:id])

    @assign = params[:assign]
    @user_id = params[:playlist][:user_id]
    unless (@assign.nil? and @user_id.nil?)
      
    end
    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        flash[:notice] = 'Playlist was successfully updated.'
        format.html { redirect_to(@playlist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /playlists/1
  # PUT /playlists/1.xml
  # Assign 1 or more test cases on this playlist
  def assign
    @playlist = Playlist.find(params[:id])
    @ids = params[:assign][:test_case_ids]
    @user_id = params[:playlist][:user_id]
    respond_to do |format|
      if (@user_id && @ids)
        @playlist_test_cases = PlaylistTestCase.find(:all, :conditions => "playlist_test_cases.id IN (#{@ids})")
        @playlist_test_cases.collect { |p| p.update_attributes(:user_id => @user_id )}      
        flash[:notice] = 'Playlist was successfully updated.'
        format.html { redirect_to(@playlist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end    
    end
  end

  # PUT /playlists/1
  # PUT /playlists/1.xml
  # Assign 1 or more test cases on this playlist
  def pass
    @playlist = Playlist.find(params[:id])
    @ids = params[:pass][:test_case_ids]
      
    respond_to do |format|
      if (@ids)
        @playlist_test_cases = PlaylistTestCase.find(:all, :conditions => "playlist_test_cases.id IN (#{@ids})")
        @playlist_test_cases.collect { |p| p.pass_by!(current_user.id) }
        flash[:notice] = 'Playlist was successfully updated.'
        format.html { redirect_to(@playlist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end    
    end
  end

  # PUT /playlists/1
  # PUT /playlists/1.xml
  # Un assign 1 or more test cases on this playlist
  def remove
    @playlist = Playlist.find(params[:id]) # find it
    @playlist = current_user.group.playlists.find(params[:id]) # verify ownership 
    @ids = params[:remove][:test_case_ids]
      
    respond_to do |format|
      if (@ids)
        @playlist_test_cases = PlaylistTestCase.find(:all, :conditions => "playlist_test_cases.id IN (#{@ids})")
        @playlist_test_cases.collect { |p| p.destroy }
        flash[:notice] = 'Playlist was successfully updated.'
        format.html { redirect_to(@playlist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist.errors, :status => :unprocessable_entity }
      end    
    end
  end

  # PUT /playlists/1/sequence
  def sequence
    @playlist = Playlist.find(params[:id])
    @pairs = params[:sequence][:id_value_pairs].split(',').collect { |p| p.split '=' }
    @pairs.collect { |p| @playlist.playlist_test_cases.find(p[0]).insert_at(p[1]) }
    redirect_to(@playlist)
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.xml
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    respond_to do |format|
      format.html { redirect_to(playlists_url) }
      format.xml  { head :ok }
    end
  end
end
