require File.dirname(__FILE__) + '/../test_helper'
require 'test_case_executions_controller'

# Re-raise errors caught by the controller.
class TestCaseExecutionsController; def rescue_action(e) raise e end; end

class TestCaseExecutionsControllerTest < Test::Unit::TestCase
  fixtures :test_case_executions

  def setup
    @controller = TestCaseExecutionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:test_case_executions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_test_case_execution
    assert_difference('TestCaseExecution.count') do
      post :create, :test_case_execution => { }
    end

    assert_redirected_to test_case_execution_path(assigns(:test_case_execution))
  end

  def test_should_show_test_case_execution
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_test_case_execution
    put :update, :id => 1, :test_case_execution => { }
    assert_redirected_to test_case_execution_path(assigns(:test_case_execution))
  end

  def test_should_destroy_test_case_execution
    assert_difference('TestCaseExecution.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to test_case_executions_path
  end
end
