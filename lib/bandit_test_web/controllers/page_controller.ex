defmodule BanditTestWeb.PageController do
  use BanditTestWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def fetch(conn, %{"id" => id}) do
    id = String.to_integer(id)

    json(
      conn,
      %{
        id: id,
        next_url: "#catalog/#{id + 1}",
        image_path: ~p"/images/logo.svg?v=#{id}"
      }
    )
  end
end
