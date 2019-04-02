defmodule Blog.Repo.Migrations.PostIdFkOnComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      modify :post_id, references(:posts)
    end
  end
end
