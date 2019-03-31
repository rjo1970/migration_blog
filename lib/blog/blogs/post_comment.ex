defmodule Blog.Blogs.PostComment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Blogs.{Post, Comment}

  schema "posts_comments" do
    belongs_to(:post, Post)
    belongs_to(:comment, Comment)

    timestamps()
  end

  @doc false
  def changeset(post_comment, attrs) do
    post_comment
    |> cast(attrs, [:post_id, :comment_id])
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:comment_id)
    # First sign of trouble...
    |> unique_constraint(:comment_id)
  end
end
