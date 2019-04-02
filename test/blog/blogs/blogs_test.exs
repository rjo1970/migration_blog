defmodule Blog.BlogsTest do
  use Blog.DataCase

  alias Blog.Blogs

  describe "posts" do
    alias Blog.Blogs.Post

    @valid_attrs %{body: "some body", title: "some title"}
    @update_attrs %{body: "some updated body", title: "some updated title"}
    @invalid_attrs %{body: nil, title: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Blogs.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blogs.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blogs.get_post!(post.id).id == post.id
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Blogs.create_post(@valid_attrs)
      assert post.body == "some body"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blogs.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Blogs.update_post(post, @update_attrs)
      assert post.body == "some updated body"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blogs.update_post(post, @invalid_attrs)

      assert post.title == Blogs.get_post!(post.id).title
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blogs.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blogs.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blogs.change_post(post)
    end
  end

  describe "comments" do
    alias Blog.Blogs.Comment

    @valid_attrs %{snark: "some snark"}
    @update_attrs %{snark: "some updated snark"}
    # @invalid_attrs %{snark: nil}

    def comment_fixture(attrs \\ %{}) do
      post = post_fixture(%{title: "a post", body: "a body"})

      {:ok, comment} =
        attrs
        |> Map.put(:post_id, post.id)
        |> Enum.into(@valid_attrs)
        |> Blogs.create_comment()

      comment
    end

    test "list_comments/0 returns all comments" do
      _comment = comment_fixture()
      assert Blogs.list_comments() |> Enum.count == 1
    end

    # test "get_comment!/1 returns the comment with given id" do
    #   comment = comment_fixture()
    #   assert Blogs.get_comment!(comment.id) == comment
    # end

    # test "create_comment/1 with valid data creates a comment" do
    #   assert {:ok, %Comment{} = comment} = Blogs.create_comment(@valid_attrs)
    #   assert comment.snark == "some snark"
    # end

    # test "create_comment/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = Blogs.create_comment(@invalid_attrs)
    # end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{} = comment} = Blogs.update_comment(comment, @update_attrs)
      assert comment.snark == "some updated snark"
    end

    # test "update_comment/2 with invalid data returns error changeset" do
    #   comment = comment_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Blogs.update_comment(comment, @invalid_attrs)
    #   assert comment == Blogs.get_comment!(comment.id)
    # end

    # test "delete_comment/1 deletes the comment" do
    #   comment = comment_fixture()
    #   assert {:ok, %Comment{}} = Blogs.delete_comment(comment)
    #   assert_raise Ecto.NoResultsError, fn -> Blogs.get_comment!(comment.id) end
    # end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Blogs.change_comment(comment)
    end
  end
end
