require File.dirname(__FILE__) + '/../test_helper'
require 'tag_favorites_controller'

# Re-raise errors caught by the controller.
class TagFavoritesController; def rescue_action(e) raise e end; end

class TagFavoritesControllerTest < Test::Unit::TestCase
  fixtures :tag_favorites

  def setup
    @controller = TagFavoritesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tag_favorites)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_tag_favorite
    assert_difference('TagFavorite.count') do
      post :create, :tag_favorite => { }
    end

    assert_redirected_to tag_favorite_path(assigns(:tag_favorite))
  end

  def test_should_show_tag_favorite
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_tag_favorite
    put :update, :id => 1, :tag_favorite => { }
    assert_redirected_to tag_favorite_path(assigns(:tag_favorite))
  end

  def test_should_destroy_tag_favorite
    assert_difference('TagFavorite.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to tag_favorites_path
  end
end
