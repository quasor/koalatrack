class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :login_required, :only => [:destroy]
###  ssl_required :show  
  
  alias authorized? admin?
  
  def index
    @users = current_user.admin? ? User.find(:all, :order => :login) : current_user.group.users
  end

  # render new.rhtml
  def new
  end

  # render new.rhtml
  def edit
    @user = User.find params[:id]
    if !current_user.group_admin? && @user.id != current_user.id
      return redirect_to users_path
    end       
  end
  
  def show
    @user = User.find params[:id]
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    flash[:notice] = "Thanks for signing up!"
    # logout the user
    cookies.delete :auth_token
    reset_session
    redirect_to '/'
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    if !(current_user.group_admin? || current_user.admin?) && @user.id != current_user.id 
      return redirect_to users_path
    end
    unless current_user.admin? #(current_user.role_id > params[:user][:role_id].to_i) #prevent user escalation
      params[:user].delete :role_id
    end 
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(users_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /test_cases/1
  # DELETE /test_cases/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

end
