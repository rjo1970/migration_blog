defmodule Blog.ETL.MovePostIdToCommentsTest do
  use Blog.DataCase
  alias Blog.ETL.MovePostIdToComments.{Post, Comment, PostComment}
  alias Blog.Repo

  describe "updating existing data to relate a comment to a post" do
    test "a comment belongs_to a post" do
      post =
        %Post{}
        |> Repo.insert!()

      comment =
        %Comment{}
        |> Repo.insert!()

      %PostComment{post_id: post.id, comment_id: comment.id}
      |> Repo.insert!()

      Blog.ETL.MovePostIdToComments.run()

      result = Repo.get!(Comment, comment.id)
      assert result.post_id == post.id
    end
  end
end
