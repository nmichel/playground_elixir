defmodule Tuto.Auth.PlugsTest do
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

  defmodule RouterNotLoaded do
    use Plug.Router

    plug :match
    plug Tuto.Auth.Plug.EnsureNotLoaded
    plug :dispatch

    post "/session" do
      conn
    end
  end

  describe "test unauthorized routes" do
    test "test EnsureNotLoaded" do
      opts = RouterNotLoaded.init([])

      conn = 
        conn(:post, "/session")
        |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))
        |> RouterNotLoaded.call(opts)

      assert conn.halted == false
    end

    test "test EnsureNotLoaded failed when a user is set on connexion" do
      opts = RouterNotLoaded.init([])
      fake_user = %User{}

      conn = 
        conn(:post, "/session")
        |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))
        |> assign(:current_user, fake_user) # set (Artificially) a fake user on the connexion
        |> RouterNotLoaded.call(opts)

      assert conn.halted == true
    end
  end

  defmodule RouterLoaded do
    use Plug.Router

    plug :match
    plug Tuto.Auth.Plug.EnsureLoaded
    plug :dispatch

    post "/session" do
      conn
    end
  end

  describe "test authorized routes" do
    test "test EnsureLoaded" do
      opts = RouterLoaded.init([])
      fake_user = %User{}

      conn = 
        conn(:post, "/session")
        |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))
        |> assign(:current_user, fake_user) # set (Artificially) a fake user on the connexion
        |> RouterLoaded.call(opts)

      assert conn.halted == false
    end

    test "test EnsureLoaded failed when no user is set on connexion" do
      opts = RouterLoaded.init([])

      conn = 
        conn(:post, "/session")
        |> put_req_header("content-type", "application/json")
        |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))
        |> RouterLoaded.call(opts)

      assert conn.halted == true
    end
  end

  defmodule LoadFromSessionRouter do
    use Plug.Router
    import Plug.Conn

    plug :match
    plug Plug.Session, store:           Plug.Session.COOKIE,
                       key:             "my_cookie_key",
                       encryption_salt: "azerty",
                       signing_salt:    "ytreza",
                       log:             true
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
  
  describe "test authentication" do
    test "plug LoadUser loads nothing when no :user_id key in session" do
      opts = LoadFromSessionRouter.init([])

      conn = 
        conn(:get, "/session")
        |> LoadFromSessionRouter.call(opts)

      assert conn.assigns[:current_user] == nil
    end

    test "user is assigned to connexion when authentication succeeded" do
      opts = LoadFromSessionRouter.init([])

      conn = 
        conn(:post, "/session")
        |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))
        |> LoadFromSessionRouter.call(opts)

      assert conn.status == 200
      assert %User{name: "john"} = conn.assigns[:current_user]
      assert %{"my_cookie_key" => %{value: session_cookie}} = conn.resp_cookies

      conn =
        conn(:get, "/session")
        |> Map.put(:req_headers, [{"cookie", "my_cookie_key=#{session_cookie};"}])
        |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))
        |> LoadFromSessionRouter.call(opts)

      assert %User{:id => 1, :name => "john"} == conn.assigns[:current_user]
    end
  end
end
