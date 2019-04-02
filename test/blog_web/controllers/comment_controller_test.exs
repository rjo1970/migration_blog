defmodule BlogWeb.CommentControllerTest do
  use BlogWeb.ConnCase

  alias Blog.Blogs

  @create_attrs %{snark: "some snark"}
  # @update_attrs %{snark: "some updated snark"}
  # @invalid_attrs %{snark: nil}

  def fixture(:comment) do
    {:ok, post} = Blogs.create_post(%{title: "a title", body: "a body"})

    {:ok, comment} =
      @create_attrs
      |> Map.put(:post_id, post.id)
      |> Blogs.create_comment()

    comment
  end

  describe "index" do
    test "lists all comments", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Comments"
    end
  end

  describe "new comment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :new))
      assert html_response(conn, 200) =~ "New Comment"
    end
  end

  # describe "create comment" do
  #   test "redirects to show post when data is valid", %{conn: conn} do
  #     {:ok, post} = Blogs.create_post(%{title: "a title", body: "a body"})

  #     conn =
  #       conn
  #       |> fetch_session()
  #       |> put_session(:post_id, post.id)
  #       |> post(Routes.comment_path(conn, :create), comment: @create_attrs)

  #     assert html_response(conn, 200) == Routes.post_path(conn, :show, post.id)
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = {:ok, post} = Blogs.create_post(%{title: "a title", body: "a body"})

  #     conn =
  #       conn
  #       |> fetch_session()
  #       |> put_session(:post_id, post.id)

  #     post(Routes.comment_path(conn, :create), comment: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "New Comment"
  #   end
  # end

  # defp create_comment(_) do
  #   comment = fixture(:comment)
  #   {:ok, comment: comment}
  # end
end
