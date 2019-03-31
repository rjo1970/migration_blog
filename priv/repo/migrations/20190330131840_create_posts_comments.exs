defmodule Blog.Repo.Migrations.CreatePostsComments do
  use Ecto.Migration

  def change do
    create table(:posts_comments) do
      add :post_id, references(:posts, on_delete: :nothing)
      add :comment_id, references(:comments, on_delete: :nothing)

      timestamps()
    end

    create index(:posts_comments, [:post_id])
    create index(:posts_comments, [:comment_id])
  end
end
