class TestCasesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  
  # GET /test_cases
  # GET /test_cases.xml
  def index
      if params[:category_id]
        @category = Category.find(params[:category_id])
        @test_cases =  TestCase.find(:all, :conditions => {:category_id => params[:category_id]})  
      elsif params[:q]
        #@match_all = params[:match_all]
        #@test_cases = TestCase.find_tagged_with(params[:q], :match_all => @match_all == "true")
        @test_cases = TestCase.find_by_contents( params[:q], :limit => 100 )
        @total_hits = @test_cases.total_hits
      else
        @test_cases = []
      end

      if logged_in?
        @playlists = current_user.playlists 
        @playlist_collection = current_user.playlists.collect {|p| [ "#{p.milestone} - #{p.title}", p.id ] }.reverse
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
    @test_case = TestCase.new( :user_id => current_user, :category_id => params[:category_id] )

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test_case }
    end
  end

  # GET /test_cases/1/edit
  def edit
    @test_case = TestCase.find(params[:id])
  end

  # POST /test_cases
  # POST /test_cases.xml
  def create
    @test_case = TestCase.new(params[:test_case])
    @test_case.updated_by = current_user.id if logged_in?
    @test_case.tags_list_string = params[:test_case][:tag_list]

    respond_to do |format|
      if @test_case.save
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
    @test_case = TestCase.find(params[:id])
    @test_case.updated_by = current_user.id if logged_in?
    @test_case.tags_list_string = params[:test_case][:tag_list]

    respond_to do |format|
      if @test_case.update_attributes(params[:test_case])
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
