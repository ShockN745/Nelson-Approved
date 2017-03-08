defmodule NelsonApproved.UserFoodControllerTest do
  use NelsonApproved.ConnCase

  alias NelsonApproved.UserFood
  @valid_attrs %{approved: true, name: "some content"}
  @invalid_attrs %{}

  setup(%{conn: conn} = context) do
    if context[:logged_in] do
      conn =
        conn
        |> login(true, false)

      conn_with_user =
        conn
        |> bypass_through(NelsonApproved.Router, :browser)
        |> get("/go_through and load user")

      %{conn: conn, user: conn_with_user.assigns.current_user}
    else
      %{conn: conn}
    end
  end

  test "not logged-in, cannot access user-food", %{conn: conn} do
    Enum.each([
      get(conn, user_food_path(conn, :index)),
      get(conn, user_food_path(conn, :new)),
      post(conn, user_food_path(conn, :create), user_food: %{}),
      delete(conn, user_food_path(conn, :delete, 1))
    ], fn(conn) ->
      assert get_flash(conn, :error) =~ "must be logged-in"
      assert redirected_to(conn) =~ session_path(conn, :new)
    end)
  end

  @tag :logged_in
  test "lists all entries on index", %{conn: conn, user: user} do
    # Given: User has food
    insert_user_food(user, "banana")

    # When: Listing all foods
    conn = get conn, user_food_path(conn, :index)

    # Then: Page renders, with expected food
    assert html_response(conn, 200) =~ "Listing user foods"
    assert html_response(conn, 200) =~ "banana"
  end

  @tag :logged_in
  test "list only entries of current user", %{conn: conn, user: user} do
    # Given: User and another user have food
    other_user = insert_user(username: "Other")
    insert_user_food(other_user, "chili")
    insert_user_food(user, "banana")

    # When: Listing all foods
    conn = get conn, user_food_path(conn, :index)

    # Then: Only food of curent user are listed
    assert html_response(conn, 200) =~ "Listing user foods"
    assert html_response(conn, 200) =~ "banana"
    refute html_response(conn, 200) =~ "chili"
  end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, user_food_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New user food"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, user_food_path(conn, :create), user_food: @valid_attrs
  #   assert redirected_to(conn) == user_food_path(conn, :index)
  #   assert Repo.get_by(UserFood, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_food_path(conn, :create), user_food: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New user food"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   user_food = Repo.insert! %UserFood{}
  #   conn = get conn, user_food_path(conn, :show, user_food)
  #   assert html_response(conn, 200) =~ "Show user food"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, user_food_path(conn, :show, -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   user_food = Repo.insert! %UserFood{}
  #   conn = get conn, user_food_path(conn, :edit, user_food)
  #   assert html_response(conn, 200) =~ "Edit user food"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   user_food = Repo.insert! %UserFood{}
  #   conn = put conn, user_food_path(conn, :update, user_food), user_food: @valid_attrs
  #   assert redirected_to(conn) == user_food_path(conn, :show, user_food)
  #   assert Repo.get_by(UserFood, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user_food = Repo.insert! %UserFood{}
  #   conn = put conn, user_food_path(conn, :update, user_food), user_food: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit user food"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   user_food = Repo.insert! %UserFood{}
  #   conn = delete conn, user_food_path(conn, :delete, user_food)
  #   assert redirected_to(conn) == user_food_path(conn, :index)
  #   refute Repo.get(UserFood, user_food.id)
  # end
end
