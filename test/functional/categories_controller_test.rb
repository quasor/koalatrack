require File.dirname(__FILE__) + '/../test_helper'
require 'categories_controller'

# Re-raise errors caught by the controller.
class CategoriesController; def rescue_action(e) raise e end; end

class CategoriesControllerTest < Test::Unit::TestCase
  fixtures :categories

  def setup
    @controller = CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_category
    assert_difference('Category.count') do
      post :create, :category => { }
    end

    assert_redirected_to category_path(assigns(:category))
  end

  def test_should_show_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_category
    put :update, :id => 1, :category => { }
    assert_redirected_to category_path(assigns(:category))
  end

  def test_should_destroy_category
    assert_difference('Category.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to categories_path
  end
end
