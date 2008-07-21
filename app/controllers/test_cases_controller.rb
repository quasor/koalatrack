class TestCasesController < ApplicationController
  before_filter :login_required
  ssl_required :show, :edit
  
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to test_cases_path
    flash[:warning] = "You do not have permission to #{action_name} that test case."      
  end
  
  # GET /test_cases
  # GET /test_cases.xml
  def index
      if params[:category_id]
        @category = Category.find(params[:category_id])
      end
      session[:last_cat_id] = params[:category_id]      
      if params[:q].nil? && @category
        @test_cases = TestCase.paginate_by_category_id @category.id, :page => params[:page], :per_page => 50, :conditions => { :active => true}  
      elsif !params[:q].blank?
        if @category.nil?
          @test_cases = TestCase.paginate_search(params[:q], {:page => params[:page], :per_page => 20}, {:order => 'category_id', :conditions => { :active => true}})                    
        else
          @test_cases = TestCase.paginate_search(params[:q] + " & ancestor_ids:#{@category.id}", {:page => params[:page], :per_page => 50}, {:order => 'category_id', :conditions => { :active => true }})
        end
      else
        @test_cases = []
      end

      if logged_in?
        @playlists = current_user.live_playlists 
        @playlist_collection = current_user.live_playlists.collect {|p| [ "#{p.title}", p.id ] }.reverse
      end
  end

  # GET /test_cases/1
  # GET /test_cases/1.xml
  def show
#    if params[:version]
#      @test_case = TestCase.find_version(params[:id], params[:version])
#    else
      @test_case = TestCase.find(params[:id])
#    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/new
  # GET /test_cases/new.xml
  def new
    @test_case = TestCase.new( :user_id => current_user.id, :category_id => params[:category_id] )

    @tag_favorites = current_user.group.tag_favorites + TagFavorite.find_all_by_group_id() + []
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/1/edit
  def edit
    @test_case = TestCase.find(params[:id])
    #@test_case.title = "Copy of #{@test_case.title}" if params[:clone]
    @tag_favorites = TagFavorite.find(:all)
  end

  # POST /test_cases
  # POST /test_cases.xml
  def create
    @uploaded_data = params[:test_case].delete :uploaded_data if params[:test_case]
    @test_case = TestCase.new(params[:test_case])
    @test_case.updated_by = current_user.id if logged_in?

    @tag_favorites = current_user.group.tag_favorites + TagFavorite.find_all_by_group_id() + []
    
    # update_tags # update the tagged attributes
    
    respond_to do |format|
      if @test_case.save
        unless @uploaded_data.blank?
          @file_attachment = FileAttachment.new({:uploaded_data => @uploaded_data})
          @test_case.file_attachments << @file_attachment
        end        
        flash[:notice] = 'TestCase was successfully created.'
        format.html { redirect_to(@test_case) }
        format.xml  { render :xml => @test_case, :status => :created, :location => @test_case }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @test_case.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /test_cases/1
  # PUT /test_cases/1.xml
  def update
    @test_case = current_user.group.test_cases.find(params[:id])
    
    @uploaded_data = params[:test_case].delete :uploaded_data
    @test_case = @test_case.clone if params[:clone]
    @test_case.updated_by = current_user.id if logged_in?
    
#    update_tags
    
    respond_to do |format|
      if @test_case.update_attributes(params[:test_case])
        unless @uploaded_data.blank?
          @file_attachment = FileAttachment.new({:uploaded_data => @uploaded_data})
          @test_case.file_attachments << @file_attachment
        end        
        flash[:notice] = 'TestCase was successfully updated.'
        format.html { redirect_to(@test_case) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @test_case.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /test_cases/1
  # DELETE /test_cases/1.xml
  def destroy
    @test_case = current_user.test_cases.find(params[:id])
    @test_case.logical_delete
  
    respond_to do |format|
      format.html { redirect_to(test_cases_path) }
      format.xml  { head :ok }
    end
  end
  
  def bulk
    flash[:notice] = 'Bulk Edit Complete'
    ids = params[:test_case][:ids1] || params[:test_case][:ids2] || params[:test_case][:ids3]
    ids = ids.split(',')
    @test_cases = TestCase.find :all, :conditions => {:id => ids}
    if params[:commit] == "Bulk Add Tag" && !params[:tag].blank? && logged_in?
      @test_cases.each do |test_case|
        test_case.updated_by = current_user.id
        test_case.tag_list.push params[:tag]
        test_case.tag_list.uniq!
        test_case.save
      end
      redirect_to test_cases_path(:category_id => session[:last_cat_id])
    elsif params[:commit] == "Bulk Add Project" && !params[:project].blank? && logged_in?
      @test_cases.each do |test_case|
        test_case.updated_by = current_user.id
        if test_case.project_id
          test_case.project_id = test_case.project_id.split(',').collect { |c| c.strip}.push(params[:project]).join(', ') unless test_case.project_id.split(',').collect { |c| c.strip}.include? params[:project]
        else
          test_case.project_id = params[:project]
        end 
        test_case.save
      end
      redirect_to test_cases_path(:category_id => session[:last_cat_id])
    elsif params[:commit] == "Bulk Move" && !params[:test_case][:category_id].blank? && logged_in?
      @test_cases.each do |test_case|
        test_case.updated_by = current_user.id
        test_case.category_id = params[:test_case][:category_id] 
        test_case.save
      end
      redirect_to test_cases_path(:category_id => params[:test_case][:category_id])
    end
  end

protected
  
  def update_tags
    if params[:test_case]
      @tags = (params[:test_case][:tag_list] || "") + (params[:quick_tag_list] || "")
      @tags = @tags.split(',').collect{ |t| t.strip }.uniq.join(', ')
      params[:test_case][:tag_list] = @tags
      @test_case.tag = params[:test_case][:tag_list]
      @tag_favorites = TagFavorite.find(:all)    
    end 
  end
end
