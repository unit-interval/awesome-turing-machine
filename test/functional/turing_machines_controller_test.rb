require 'test_helper'

class TuringMachinesControllerTest < ActionController::TestCase
  setup do
    @turing_machine = turing_machines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:turing_machines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create turing_machine" do
    assert_difference('TuringMachine.count') do
      post :create, :turing_machine => @turing_machine.attributes
    end

    assert_redirected_to turing_machine_path(assigns(:turing_machine))
  end

  test "should show turing_machine" do
    get :show, :id => @turing_machine
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @turing_machine
    assert_response :success
  end

  test "should update turing_machine" do
    put :update, :id => @turing_machine, :turing_machine => @turing_machine.attributes
    assert_redirected_to turing_machine_path(assigns(:turing_machine))
  end

  test "should destroy turing_machine" do
    assert_difference('TuringMachine.count', -1) do
      delete :destroy, :id => @turing_machine
    end

    assert_redirected_to turing_machines_path
  end
end
