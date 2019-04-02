defmodule Blog.ETL.MovePostIdToComments do
  import Ecto.Query

  defmodule Post do
    use Ecto.Schema

    schema "posts" do
      # All I need is the implicit id field
    end
  end

  defmodule Comment do
    use Ecto.Schema

    schema "comments" do
      belongs_to(:post, Blog.ETL.MovePostIdToComments.Post)
    end
  end

  defmodule PostComment do
    use Ecto.Schema

    schema "posts_comments" do
      belongs_to(:post, Blog.ETL.MovePostIdToComments.Post)
      belongs_to(:comment, Blog.ETL.MovePostIdToComments.Comment)
    end
  end

  def run() do
    Blog.Repo.transaction(fn() -> 
        comment_and_post_ids_stream()
        |> Stream.each(fn {comment_id, post_id} ->
            post =
              Blog.Repo.get!(Blog.ETL.MovePostIdToComments.Post, post_id)

             Blog.Repo.get!(Blog.ETL.MovePostIdToComments.Comment, comment_id)
             |> Blog.Repo.preload(:post)
             |> Ecto.Changeset.change(post: post)
             |> Blog.Repo.update()
        end)
        |> Enum.count()
    end)
  end

  defp comment_and_post_ids_stream() do
    from(
      pc in Blog.ETL.MovePostIdToComments.PostComment,
      select: {pc.comment_id, pc.post_id}
    )
    |> Blog.Repo.stream()      
  end
end
