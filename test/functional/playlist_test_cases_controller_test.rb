require File.dirname(__FILE__) + '/../test_helper'
require 'playlist_test_cases_controller'

# Re-raise errors caught by the controller.
class PlaylistTestCasesController; def rescue_action(e) raise e end; end

class PlaylistTestCasesControllerTest < Test::Unit::TestCase
  fixtures :playlist_test_cases

  def setup
    @controller = PlaylistTestCasesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:playlist_test_cases)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_playlist_test_case
    assert_difference('PlaylistTestCase.count') do
      post :create, :playlist_test_case => { }
    end

    assert_redirected_to playlist_test_case_path(assigns(:playlist_test_case))
  end

  def test_should_show_playlist_test_case
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_playlist_test_case
    put :update, :id => 1, :playlist_test_case => { }
    assert_redirected_to playlist_test_case_path(assigns(:playlist_test_case))
  end

  def test_should_destroy_playlist_test_case
    assert_difference('PlaylistTestCase.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to playlist_test_cases_path
  end
end
