defmodule Blog.Blogs.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :snark, :string

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:snark])
    |> validate_required([:snark])
  end
end
