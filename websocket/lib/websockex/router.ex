defmodule Websockex.Router do
  use Plug.Router

  plug :match
  plug :dispatch
  
  match _ do
    send_resp(conn, 404, "<h1>Nothing here!</h1>")
  end  
end
