class PlaylistTestCasesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  # GET /playlist_test_cases
  # GET /playlist_test_cases.xml
  def index
    @playlist_test_cases = PlaylistTestCase.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @playlist_test_cases }
    end
  end

  # GET /playlist_test_cases/1
  # GET /playlist_test_cases/1.xml
  def show
    @playlist_test_case = PlaylistTestCase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @playlist_test_case }
    end
  end

  # GET /playlist_test_cases/new
  # GET /playlist_test_cases/new.xml
  def new
    @playlist_test_case = PlaylistTestCase.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @playlist_test_case }
    end
  end

  # GET /playlist_test_cases/1/edit
  def edit
    @playlist_test_case = PlaylistTestCase.find(params[:id])
  end

  # POST /playlist_test_cases
  # POST /playlist_test_cases.xml
  def create
    @ids = params[:playlist_test_case].delete :ids
    @playlist_test_case = PlaylistTestCase.new(params[:playlist_test_case])
    @playlist_test_case.user_id = current_user.id
    respond_to do |format|
      if (@ids && create_multiple(@ids)) || @playlist_test_case.save
        flash[:notice] = 'Test cases were added to playlist.'
        format.html { redirect_to(@playlist_test_case.playlist) }
        format.xml  { render :xml => @playlist_test_case, :status => :created, :location => @playlist_test_case }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @playlist_test_case.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_multiple(ids)
    test_case_ids = ids.split(',')
    for id in test_case_ids
      @playlist_test_case = PlaylistTestCase.new(params[:playlist_test_case])
      @playlist_test_case.test_case_id = id
      @playlist_test_case.user_id = current_user.id
      @playlist_test_case.save      
    end
  end
  
  # PUT /playlist_test_cases/1
  # PUT /playlist_test_cases/1.xml
  def update
    @playlist_test_case = PlaylistTestCase.find(params[:id])

    respond_to do |format|
      if @playlist_test_case.update_attributes(params[:playlist_test_case])
        flash[:notice] = 'PlaylistTestCase was successfully updated.'
        format.html { redirect_to(@playlist_test_case) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist_test_case.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  # DELETE /playlist_test_cases/1
  # DELETE /playlist_test_cases/1.xml
  def destroy
    @playlist_test_case = PlaylistTestCase.find(params[:id])
    @playlist = @playlist_test_case.playlist
    @playlist_test_case.destroy

    respond_to do |format|
      format.html { redirect_to(@playlist) }
      format.xml  { head :ok }
    end
  end
  
  #
  protected
  def process_result(result)
    @playlist_test_case = PlaylistTestCase.find(params[:id])
    @version = @playlist_test_case.test_case_version || @playlist_test_case.test_case.version
    @tce = TestCaseExecution.create( :playlist_test_case_id => @playlist_test_case.id, 
    :test_case_id => @playlist_test_case.test_case_id, :user_id => current_user, 
    :test_case_version => @version,:result => result)                                
    
    respond_to do |format|
      if @playlist_test_case.update_attributes(params[:playlist_test_case])
        flash[:notice] = 'PlaylistTestCase was successfully updated.'
        format.html { redirect_to(@playlist_test_case) }
        format.xml  { head :ok }
        format.js   { 
          render :update do |page|
            page.visual_effect :highlight, "playlist_test_case_#{@playlist_test_case.id}" 
            page.replace_html "playlist_test_case_#{@playlist_test_case.id}_results", :partial => 'results', :collection => @tce.siblings           
          end
          }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @playlist_test_case.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
