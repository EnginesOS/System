require 'test_helper'

class EnginesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
