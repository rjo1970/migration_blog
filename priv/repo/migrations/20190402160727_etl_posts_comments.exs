defmodule Blog.Repo.Migrations.EtlPostsComments do
  use Ecto.Migration

  def up do
    Blog.ETL.MovePostIdToComments.run()
  end

  def down do
  end
end
