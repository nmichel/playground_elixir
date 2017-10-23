defmodule Tuto.Auth.Plug.LoadUser do
    import Plug.Conn

    def init(opts) do
        Keyword.fetch!(opts, :source)
    end

    def call(conn, source) do
        user_id = get_session(conn, :user_id)
        user = user_id && source.get(user_id)
        assign(conn, :current_user, user)
    end
end

defmodule Tuto.Auth.Plug.EnsureLoaded do
    import Plug.Conn

    def init(_opts) do
        :ok
    end

    def call(conn, _opts) do
        if conn.assigns[:current_user] do
            conn
        else
            halt(conn)
        end
    end
end

defmodule Tuto.Auth.Plug.EnsureNotLoaded do
    import Plug.Conn

    def init(_opts) do
        :ok
    end

    def call(conn, _opts) do
        if conn.assigns[:current_user] do
            halt(conn)
        else
            conn
        end
    end
end
