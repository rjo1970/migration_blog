defmodule Blog.Blogs.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Blogs.{Post, PostComment}

  schema "comments" do
    field :snark, :string
    has_one(:post_comment, PostComment)
    has_one(:post, through: [:post_comment, :post])

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:snark])
    |> validate_required([:snark])
  end
end
