defmodule Tuto.Plug.CookieSessionTest do
  use Tuto.Plug.ConnTestCase

  test "write and read entry in session with a COOKIE store" do
    opts = Plug.Session.init(
      # Plug.Session options
      store: Plug.Session.COOKIE,
      key: "my_cookie_key",
      # Plug.Session.COOKIE options
      encryption_salt: "azerty",
      signing_salt: "ytreza",
      log: true)

    # Emulate responding to the "GET /session" request, establishing a session cookie
    conn =
      conn(:get, "/session")
      |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10)) # Needed by Plug.Session.COOKIE
      |> Plug.Session.call(opts)                                    # Mainly attach the function used to retrieve the session from the store [set :plug_session_fetch]
      |> fetch_session()                                            # "Load" the session from the store, attach a function that updates the cookie before sending data [set :plug_session]
      |> put_session(:foo, :bar)                                    # Write a kv pair in the session [update :plug_session, set (if possible) :plug_session_info to :write (see next step)]
      |> send_resp(200, "hello world")                              # Force to update the session in the store, and set the session cookie
    assert %{"my_cookie_key" => _value} = conn.resp_cookies

    # Emulate responding to the "GET /hello" request including the session cookie
    %{"my_cookie_key" => %{value: session_cookie}} = conn.resp_cookies
    conn =
      conn(:get, "/hello")
      |> Map.put(:req_headers, [{"cookie", "my_cookie_key=#{session_cookie};"}, # Inject the previous cookie "my_cookie_key" in the request headers
                                {"cookie", "useless_cookie=bibabu;"}])          # Inject a useless cookie for fun
      |> Map.put(:secret_key_base, String.duplicate("ABCDEFG", 10))             # Use the same session config as above
      |> Plug.Session.call(opts)                                                # ...

    # Check that no session loaded yet
    assert conn.private[:plug_session] == nil

    conn =
      conn
      |> fetch_session()  # Load the session (from the previously loaded cookie "my_cookie_key") (fetch_session calls fetch_cookie itself)
      # |> send_resp(...) # Anwser the request

    # Check that session is loaded
    assert %{} = conn.private[:plug_session]

    # Yes ! Session successfully rebuilt from cookie
    assert get_session(conn, :foo) == :bar
  end
end
