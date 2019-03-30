defmodule BlogWeb.PostView do
  use BlogWeb, :view

  def as_markdown(post) do
    post.body
    |> Earmark.as_html!()
    |> raw()
  end

end
