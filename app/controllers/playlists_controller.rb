class PlaylistsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /playlists
  # GET /playlists.xml
  def index
    if logged_in?
      @my_playlists =  Playlist.find_all_by_user_id(current_user.id) 
      @playlists = Playlist.find(:all, :conditions => ["user_id != ?", current_user.id])
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
  def show
    @playlist = Playlist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @playlist }
    end
  end

  # GET /playlists/new
  # GET /playlists/new.xml
  def new
    @playlist_copy = Playlist.find(params[:id]) if params[:id]
    @playlist = Playlist.new(:title => "Copy of #{@playlist_copy.title}")
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
        if params[:clone_id]
          @playlist_test_cases = Playlist.find(params[:clone_id]).playlist_test_cases.collect(&:clone)
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
  # Assign 1 or more test cases on this playlist
  def remove
    @playlist = Playlist.find(params[:id])
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
