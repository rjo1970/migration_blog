defmodule Blog.Blogs.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Blogs.{Post, PostComment}

  schema "comments" do
    field :snark, :string
    field :post_id, :integer, virtual: true
    has_one(:post_comment, PostComment)
    has_one(:post, through: [:post_comment, :post])

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:snark, :post_id])
    |> validate_required([:snark, :post_id])
  end
end
