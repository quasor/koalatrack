require File.dirname(__FILE__) + '/../test_helper'
require 'milestones_controller'

# Re-raise errors caught by the controller.
class MilestonesController; def rescue_action(e) raise e end; end

class MilestonesControllerTest < Test::Unit::TestCase
  fixtures :milestones

  def setup
    @controller = MilestonesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:milestones)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_milestone
    assert_difference('Milestone.count') do
      post :create, :milestone => { }
    end

    assert_redirected_to milestone_path(assigns(:milestone))
  end

  def test_should_show_milestone
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_milestone
    put :update, :id => 1, :milestone => { }
    assert_redirected_to milestone_path(assigns(:milestone))
  end

  def test_should_destroy_milestone
    assert_difference('Milestone.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to milestones_path
  end
end
