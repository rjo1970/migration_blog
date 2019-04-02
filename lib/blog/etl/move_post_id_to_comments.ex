defmodule Blog.ETL.MovePostIdToComments do
  import Ecto.Query

  defmodule Post do
    use Ecto.Schema

    schema "posts" do
      # All I need is the implicit id field
      timestamps()
    end
  end

  defmodule Comment do
    use Ecto.Schema

    schema "comments" do
      belongs_to(:post, Blog.ETL.MovePostIdToComments.Post)
      timestamps()
    end
  end

  defmodule PostComment do
    use Ecto.Schema

    schema "posts_comments" do
      belongs_to(:post, Blog.ETL.MovePostIdToComments.Post)
      belongs_to(:comment, Blog.ETL.MovePostIdToComments.Comment)
      timestamps()
    end
  end

  alias Blog.ETL.MovePostIdToComments.{Post, Comment, PostComment}
  alias Blog.Repo

  def run() do
    Repo.transaction(fn ->
      comment_and_post_ids_stream()
      |> Stream.each(&update_comment/1)
      |> Enum.count()
    end)
  end

  defp update_comment({comment_id, post_id}) do
    post = Repo.get!(Post, post_id)

    Repo.get!(Comment, comment_id)
    |> Repo.preload(:post)
    |> Ecto.Changeset.change(post: post)
    |> Repo.update!()
  end

  defp comment_and_post_ids_stream() do
    from(
      pc in PostComment,
      select: {pc.comment_id, pc.post_id}
    )
    |> Repo.stream()
  end
end
