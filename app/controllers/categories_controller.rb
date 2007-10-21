class CategoriesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    redirect_to categories_path
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @parent_id = params[:parent_id]
    @category = Category.new(:parent_id => @parent_id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    if !admin?
      if @category.parent_id.nil?
         flash[:warning] = 'You cannot create a root category unless you are an admin.'
         return render :action => "new"
      end
      if group_admin? && @category.group_id != current_user.group_id
        flash[:warning] = 'You cannot create a group category unless you are an group admin.'
        return redirect_to test_cases_path(:category_id => @category.parent_id)
      end
      @category.group_id = current_user.group_id
    end
      
    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        format.html { redirect_to(test_cases_path(:category_id => @category.id)) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = current_user.group.categories.find(params[:id])
    @category.group_id = current_user.group_id

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to(@category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end
end
