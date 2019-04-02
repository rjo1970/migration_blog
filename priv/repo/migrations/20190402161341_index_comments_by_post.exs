defmodule Blog.Repo.Migrations.IndexCommentsByPost do
  use Ecto.Migration

  def change do
    create_if_not_exists index(:comments, [:post_id])
  end
end
