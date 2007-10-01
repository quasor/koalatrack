require File.dirname(__FILE__) + '/../test_helper'
require 'test_cases_controller'

# Re-raise errors caught by the controller.
class TestCasesController; def rescue_action(e) raise e end; end

class TestCasesControllerTest < Test::Unit::TestCase
  fixtures :test_cases

  def setup
    @controller = TestCasesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:test_cases)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_test_case
    assert_difference('TestCase.count') do
      post :create, :test_case => { :title => 'Foo', :body => 'Bar' }
    end

    assert_redirected_to test_case_path(assigns(:test_case))
  end

  def test_should_show_test_case
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_test_case
    put :update, :id => 1, :test_case => { :title => 'Foo', :body => 'Bar' }
    assert_redirected_to test_case_path(assigns(:test_case))
  end

  def test_should_destroy_test_case
    assert_difference('TestCase.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to test_cases_path
  end
end
