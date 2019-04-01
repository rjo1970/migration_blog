defmodule Blog.Repo.Migrations.AddJointableConstraints do
  use Ecto.Migration

  def change do
    alter table(:posts_comments) do
      modify :post_id, :integer, null: false
      modify :comment_id, :integer, null: false
    end
  end
end
