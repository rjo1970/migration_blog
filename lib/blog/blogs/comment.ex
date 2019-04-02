defmodule Blog.Blogs.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Blogs.Post

  schema "comments" do
    field :snark, :string
    belongs_to(:post, Post)

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:snark, :post_id])
    |> validate_required([:snark, :post_id])
  end
end
