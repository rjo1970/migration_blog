defmodule Blog.Repo.Migrations.AddPostIdToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add(:post_id, :integer)
    end
  end
end
