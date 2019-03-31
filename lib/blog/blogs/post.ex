defmodule Blog.Blogs.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Blogs.PostComment

  schema "posts" do
    field :body, :string
    field :title, :string
    has_many(:posts_comments, PostComment)
    has_many(:comments, through: [:posts_comments, :comment])

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
