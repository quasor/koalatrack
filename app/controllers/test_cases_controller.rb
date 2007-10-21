class TestCasesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /test_cases
  # GET /test_cases.xml
  def index
      if params[:category_id]
        @category = Category.find(params[:category_id])
      end
      if params[:q].nil? && @category
        @test_cases = TestCase.paginate_by_category_id @category.id, :page => params[:page], :per_page => 50  
      elsif params[:q]
        if @category.nil?
          @test_cases = TestCase.search(params[:q], :match_mode => Sphinx::Client::SPH_MATCH_EXTENDED, :per_page => 20, :page => params[:page])
        else
          @test_cases = TestCase.search(params[:q], :match_mode => Sphinx::Client::SPH_MATCH_EXTENDED, :per_page => 20, :page => params[:page], :conditions => { :category_id => @category.self_and_descendants.collect(&:id).sort })
        end
      else
        @test_cases = []
      end

      if logged_in?
        @playlists = current_user.playlists 
        @playlist_collection = current_user.playlists.collect {|p| [ "#{p.title}", p.id ] }.reverse
      end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @test_cases }
    end
  end

  # GET /test_cases/1
  # GET /test_cases/1.xml
  def show
    @test_case = TestCase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/new
  # GET /test_cases/new.xml
  def new
    @test_case = TestCase.new( :user_id => current_user.id, :category_id => params[:category_id] )

    @tag_favorites = current_user.admin? ? TagFavorite.find(:all) : current_user.group.tag_favorites + TagFavorite.find_all_by_group_id()
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/1/edit
  def edit
    @test_case = TestCase.find(params[:id])
    @test_case.title = "Copy of #{@test_case.title}" if params[:clone]
    @tag_favorites = TagFavorite.find(:all)
  end

  # POST /test_cases
  # POST /test_cases.xml
  def create
    @uploaded_data = params[:test_case].delete :uploaded_data
    @test_case = TestCase.new(params[:test_case])
    @test_case.updated_by = current_user.id if logged_in?
    
    update_tags
    
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

  def update_tags
    @tags = (params[:test_case][:tag_list] || "") + (params[:quick_tag_list] || "")
    @tags = @tags.split(',').collect{ |t| t.strip }.uniq.join(', ')
    params[:test_case][:tag_list] = @tags
    @test_case.tag = params[:test_case][:tag_list]
  end

  # PUT /test_cases/1
  # PUT /test_cases/1.xml
  def update
    @uploaded_data = params[:test_case].delete :uploaded_data
    @test_case = TestCase.find(params[:id])
    @test_case = @test_case.clone if params[:clone]
    @test_case.updated_by = current_user.id if logged_in?
    
    update_tags
    
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
    @test_case = TestCase.find(params[:id])
    @test_case.destroy

    respond_to do |format|
      format.html { redirect_to(test_cases_url) }
      format.xml  { head :ok }
    end
  end
end
