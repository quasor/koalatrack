require File.dirname(__FILE__) + '/../test_helper'
require 'groups_controller'

# Re-raise errors caught by the controller.
class GroupsController; def rescue_action(e) raise e end; end

class GroupsControllerTest < Test::Unit::TestCase
  fixtures :groups

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_group
    assert_difference('Group.count') do
      post :create, :group => { }
    end

    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_show_group
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_group
    put :update, :id => 1, :group => { }
    assert_redirected_to group_path(assigns(:group))
  end

  def test_should_destroy_group
    assert_difference('Group.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to groups_path
  end
end
