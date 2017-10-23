defmodule Tuto.Auth.StoreTests do
  use Tuto.Plug.ConnTestCase

  defmodule User do
    defstruct [:name, :id]
  end

  defmodule Source do
    def get(1) do
      %User{id: 1, name: "john"}
    end
    def get(_) do
      nil
    end

    def check_and_load("john", "nhoj") do
      {:ok,%User{id: 1, name: "john"}}
    end
    def check_and_load("john", _) do
      {:error, :unauthorized}
    end
    def check_and_load(_, _) do
      {:error, :not_found}
    end
  end

  defmodule Router do
    use Plug.Router
    import Plug.Conn

    plug :match
    plug Plug.Session, store: Tuto.Auth.Store,
                       key: "my_session_key",
                       file: "store.txt"
    plug :fetch_session
    plug Tuto.Auth.Plug.LoadUser, source: Source
    plug :dispatch

    get "/session" do
      send_resp(conn, 200, "checked")
    end

    post "/session" do
      case Tuto.Auth.Helpers.authenticate(conn, "john", "nhoj", source: Source) do
        {:ok, conn} ->
          send_resp(conn, 200, "authenticated")
        {:error, _} ->
          send_resp(conn, 404, "not authenticated")
      end
    end
  end

  test "user is assigned to connexion when authentication succeeded" do
    opts = Router.init([])

    conn = 
      conn(:post, "/session")
      |> Router.call(opts)

    assert conn.status == 200
    assert %User{name: "john"} = conn.assigns[:current_user]
    assert %{"my_session_key" => %{value: session_cookie}} = conn.resp_cookies

    conn =
      conn(:get, "/session")
      |> Map.put(:req_headers, [{"cookie", "my_session_key=#{session_cookie};"}])
      |> Router.call(opts)

    assert %User{:id => 1, :name => "john"} == conn.assigns[:current_user]
  end
end