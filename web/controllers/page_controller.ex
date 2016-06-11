defmodule Oxo.PageController do
  use Oxo.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
