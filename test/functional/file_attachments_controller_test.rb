require File.dirname(__FILE__) + '/../test_helper'
require 'file_attachments_controller'

# Re-raise errors caught by the controller.
class FileAttachmentsController; def rescue_action(e) raise e end; end

class FileAttachmentsControllerTest < Test::Unit::TestCase
  fixtures :file_attachments

  def setup
    @controller = FileAttachmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:file_attachments)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_file_attachment
    assert_difference('FileAttachment.count') do
      post :create, :file_attachment => { }
    end

    assert_redirected_to file_attachment_path(assigns(:file_attachment))
  end

  def test_should_show_file_attachment
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_file_attachment
    put :update, :id => 1, :file_attachment => { }
    assert_redirected_to file_attachment_path(assigns(:file_attachment))
  end

  def test_should_destroy_file_attachment
    assert_difference('FileAttachment.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to file_attachments_path
  end
end
