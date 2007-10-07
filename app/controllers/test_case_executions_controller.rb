class TestCaseExecutionsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  in_place_edit_for :word, :title, :empty_text => '...'
  
  # GET /test_case_executions
  # GET /test_case_executions.xml
  def index
    @test_case_executions = TestCaseExecution.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @test_case_executions }
    end
  end

  # GET /test_case_executions/1
  # GET /test_case_executions/1.xml
  def show
    @test_case_execution = TestCaseExecution.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @test_case_execution }
    end
  end

  # GET /test_case_executions/new
  # GET /test_case_executions/new.xml
  def new
    @test_case_execution = TestCaseExecution.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @test_case_execution }
    end
  end

  # GET /test_case_executions/1/edit
  def edit
    @test_case_execution = TestCaseExecution.find(params[:id])
  end

  # POST /test_case_executions
  # POST /test_case_executions.xml
  def create
    @test_case_execution = TestCaseExecution.new(params[:test_case_execution])
    @test_case_execution.user_id = current_user.id
    respond_to do |format|
      if @test_case_execution.save
        flash[:notice] = 'TestCaseExecution was successfully created.'
        format.html { redirect_to(@test_case_execution.playlist) }
        format.xml  { render :xml => @test_case_execution, :status => :created, :location => @test_case_execution }
        format.js do
           render :update do |page|
           end
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @test_case_execution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /test_case_executions/1
  # PUT /test_case_executions/1.xml
  def update
    @test_case_execution = TestCaseExecution.find(params[:id])

    respond_to do |format|
      if @test_case_execution.update_attributes(params[:test_case_execution])
        flash[:notice] = 'TestCaseExecution was successfully updated.'
        format.html { redirect_to(@test_case_execution) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @test_case_execution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /test_case_executions/1
  # DELETE /test_case_executions/1.xml
  def destroy
    @test_case_execution = TestCaseExecution.find(params[:id])
    @test_case_execution.destroy

    respond_to do |format|
      format.html { redirect_to(test_case_executions_url) }
      format.xml  { head :ok }
    end
  end
end
